# Most of the classes here have been documented already.
# rubocop:disable Style/Documentation
module Yixe::IR # :nodoc: all
  using Nix::StringUtils

  class Node
    # FIXME: must attach the node's position into the output as a comment!
    def to_nix()
      raise "`#to_nix` not defined for #{self.class.name.inspect}"
    end

    def generate_section(name, code)
      [
        "",
        "#",
        "# #{name}",
        "#",
        code,
        "",
      ].join("\n")
    end
  end

  class String
    def to_nix()
      # Close enough
      @value.to_nix()
    end
  end

  class Null
    def to_nix()
      "null"
    end
  end

  class Boolean
    def to_nix()
      @value.to_json()
    end
  end

  class Number
    def to_nix()
      @value.to_json()
    end
  end

  class Path
    def to_nix()
      value
    end
  end

  class Mapping
    def to_nix()
      attrs = Nix::Attrs.new()
      each do |k, v|
        attrs[k] = v
      end
      attrs.to_nix()
    end
  end

  class List
    def to_nix()
      list = Nix::List.new()
      map do |v|
        list.append(v)
      end
      list.to_nix()
    end
  end

  class Root
    def to_nix()
      [
        "(",
        "#" * 80,
        "# Transpiled by Yixe",
        "#" * 80,
        "# Document metadata:",
        "#      type: #{document_type.inspect}",
        "#   version: #{version.inspect}",
        "#" * 80,
        "#",
        send(["transpile", document_type].join("_").gsub("-", "_").to_sym),
        "#",
        "#" * 80,
        ")",
      ].join("\n")
    end

    def transpile_yixe_project()
      # TODO: support set-pattern arguments

      toplevel = Nix::Let.new()
      toplevel.value = Nix::Raw.new("__yixe_top")

      attrs = Nix::Attrs.new()

      if (inputs = get("inputs"))
        attrs["inputs"] = inputs
      end

      if (outputs = get("outputs"))
        outputs.each do |k, v|
          attrs[k] = v
        end
      end

      toplevel["__yixe_top"] = attrs

      toplevel.to_nix
    end

    def transpile_yixe_expression(body: nil)
      is_set_pattern = !get("arguments").nil?

      body ||= get("output")

      if is_set_pattern
        args = get("arguments").map do |arg|
          case arg
          when Yixe::IR::String
            Nix::Raw.new(arg.value)
          when Yixe::IR::Tag::NixRaw
            arg
          # TODO: support default values with a singlet mapping
          else
            raise "Unhandled argument of type #{arg.class.name.inspect} for yixe expression arguments."
          end
        end
        args = Nix::SetPattern.new(*args)
        Nix::FunctionDefinition.new(args, body).to_nix()
      else
        body.to_nix()
      end
    end

    # For "NixOS modules system" configuration.
    def transpile_yixe_module()
      body = Nix::Attrs.new()
      [
        "options",
        "config",
      ].each do |name|
        body[name] = get(name) if get(name)
      end
      if (imports = get("imports"))
        body["imports"] = Nix::List.new()
        imports.map do |entry|
          case entry
          when Yixe::IR::String, Yixe::IR::Path
            str = entry.value
            # TODO: transform string to paths implicitly more globally somehow?
            if str.match(%r{^\./}) || str.match(%r{^/}) || str.match(/^<.*>$/)
              if str.match(/\.yixe$/)
                value = Tag::YixeImportDocument.new(node: entry.node, visitor: @visitor)
                body["imports"].append(value)
              else
                # Assume writer used a `.nix` file, and import that.
                # TODO: support `import ./directory` for implicit yixe load?
                body["imports"].append(Nix::Raw.new(str))
              end
            else
              body["imports"].append(entry)
            end
          when Yixe::IR::Mapping
            body["imports"].append(entry)
          else
            raise "TODO: handle #{entry.class.name.inspect} in transpile_yixe_module"
          end
        end
      end
      transpile_yixe_expression(body: body)
    end

    def transpile_yixe_nixpkgs_package()
      output = get("output")
      builder = "stdenv.mkDerivation"
      if output.get("builder")
        builder =
          output.consume!("builder").value
      end

      arguments = get("arguments")
      error(
        message: "arguments must be a List",
        target: arguments,
      ) unless arguments.is_a?(List)
      [builder.split(".").first, "lib"].each do |value|
        next if arguments.any? do |arg|
          arg.value.match(value) if arg.value.respond_to?(:match)
        end

        arg_node = Psych::Nodes::Scalar.new(value, tag: "!nix")
        arguments.prepend(
          Yixe::IR::String.new(
            visitor: @visitor,
            node: arg_node,
          ),
        )
      end

      # Attributes we're transforming.
      drv_attrs = Nix::Attrs.new()

      if output.get("version")
        drv_attrs["pname"] = output.consume!("name")
        drv_attrs["version"] = output.consume!("version")
      end

      if output.get("environment")
        drv_attrs["env"] =
          output.consume!("environment")
      end

      body =
        Nix::FunctionCall.new(
          Nix::Raw.new(builder),
          Nix::MergeAttrs.new(*[
            output,
            drv_attrs,
          ].compact()),
        )

      transpile_yixe_expression(body: body)
    end
  end

  class Outputs
    def to_nix()
      raise "No to_nix on outputs; handled in its parent document."
    end
  end
end
