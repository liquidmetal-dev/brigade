defmodule Flintlock.Types.MicroVM do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MicroVM",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "version",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "version",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "spec",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMSpec",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "spec",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMStatus",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:version, 1, type: :int32)
  field(:spec, 2, type: Flintlock.Types.MicroVMSpec)
  field(:status, 3, type: Flintlock.Types.MicroVMStatus)
end

defmodule Flintlock.Types.MicroVMSpec.LabelsEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "LabelsEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Flintlock.Types.MicroVMSpec.MetadataEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MetadataEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Flintlock.Types.MicroVMSpec do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MicroVMSpec",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "namespace",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "namespace",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "labels",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMSpec.LabelsEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "labels",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "vcpu",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "vcpu",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "memory_in_mb",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "memoryInMb",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "kernel",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Kernel",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "kernel",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "initrd",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Initrd",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "initrd",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "root_volume",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Volume",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "rootVolume",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "additional_volumes",
          extendee: nil,
          number: 9,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Volume",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "additionalVolumes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "interfaces",
          extendee: nil,
          number: 10,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.NetworkInterface",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "interfaces",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 11,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMSpec.MetadataEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "created_at",
          extendee: nil,
          number: 12,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "createdAt",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "updated_at",
          extendee: nil,
          number: 13,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "updatedAt",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "deleted_at",
          extendee: nil,
          number: 14,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deletedAt",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uid",
          extendee: nil,
          number: 15,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "uid",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "provider",
          extendee: nil,
          number: 16,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "provider",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "LabelsEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.DescriptorProto{
          name: "MetadataEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_initrd",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_uid",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_provider",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:id, 1, type: :string)
  field(:namespace, 2, type: :string)
  field(:labels, 3, repeated: true, type: Flintlock.Types.MicroVMSpec.LabelsEntry, map: true)
  field(:vcpu, 4, type: :int32)
  field(:memory_in_mb, 5, type: :int32, json_name: "memoryInMb")
  field(:kernel, 6, type: Flintlock.Types.Kernel)
  field(:initrd, 7, proto3_optional: true, type: Flintlock.Types.Initrd)
  field(:root_volume, 8, type: Flintlock.Types.Volume, json_name: "rootVolume")

  field(:additional_volumes, 9,
    repeated: true,
    type: Flintlock.Types.Volume,
    json_name: "additionalVolumes"
  )

  field(:interfaces, 10, repeated: true, type: Flintlock.Types.NetworkInterface)
  field(:metadata, 11, repeated: true, type: Flintlock.Types.MicroVMSpec.MetadataEntry, map: true)
  field(:created_at, 12, type: Google.Protobuf.Timestamp, json_name: "createdAt")
  field(:updated_at, 13, type: Google.Protobuf.Timestamp, json_name: "updatedAt")
  field(:deleted_at, 14, type: Google.Protobuf.Timestamp, json_name: "deletedAt")
  field(:uid, 15, proto3_optional: true, type: :string)
  field(:provider, 16, proto3_optional: true, type: :string)
end

defmodule Flintlock.Types.Kernel.CmdlineEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CmdlineEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Flintlock.Types.Kernel do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Kernel",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "image",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "image",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "cmdline",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Kernel.CmdlineEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "cmdline",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "filename",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "filename",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "add_network_config",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "addNetworkConfig",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "CmdlineEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_filename",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:image, 1, type: :string)
  field(:cmdline, 2, repeated: true, type: Flintlock.Types.Kernel.CmdlineEntry, map: true)
  field(:filename, 3, proto3_optional: true, type: :string)
  field(:add_network_config, 4, type: :bool, json_name: "addNetworkConfig")
end

defmodule Flintlock.Types.Initrd do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Initrd",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "image",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "image",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "filename",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "filename",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_filename",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:image, 1, type: :string)
  field(:filename, 2, proto3_optional: true, type: :string)
end

defmodule Flintlock.Types.NetworkInterface.IfaceType do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "IfaceType",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "MACVTAP",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TAP",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:MACVTAP, 0)
  field(:TAP, 1)
end

defmodule Flintlock.Types.NetworkInterface do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NetworkInterface",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "device_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deviceId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".flintlock.types.NetworkInterface.IfaceType",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "type",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "guest_mac",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "guestMac",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "address",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.StaticAddress",
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "address",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "overrides",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.NetworkOverrides",
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "overrides",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "IfaceType",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "MACVTAP",
              number: 0,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "TAP",
              number: 1,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          options: nil,
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_guest_mac",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_address",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_overrides",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:device_id, 1, type: :string, json_name: "deviceId")
  field(:type, 2, type: Flintlock.Types.NetworkInterface.IfaceType, enum: true)
  field(:guest_mac, 4, proto3_optional: true, type: :string, json_name: "guestMac")
  field(:address, 5, proto3_optional: true, type: Flintlock.Types.StaticAddress)
  field(:overrides, 6, proto3_optional: true, type: Flintlock.Types.NetworkOverrides)
end

defmodule Flintlock.Types.StaticAddress do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StaticAddress",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "address",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "address",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "gateway",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "gateway",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nameservers",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nameservers",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_gateway",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:address, 1, type: :string)
  field(:gateway, 2, proto3_optional: true, type: :string)
  field(:nameservers, 3, repeated: true, type: :string)
end

defmodule Flintlock.Types.Volume do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Volume",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "is_read_only",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "isReadOnly",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "mount_point",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "mountPoint",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "source",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.VolumeSource",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "source",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "partition_id",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "partitionId",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "size_in_mb",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "sizeInMb",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_mount_point",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_partition_id",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_size_in_mb",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:id, 1, type: :string)
  field(:is_read_only, 2, type: :bool, json_name: "isReadOnly")
  field(:mount_point, 3, proto3_optional: true, type: :string, json_name: "mountPoint")
  field(:source, 4, type: Flintlock.Types.VolumeSource)
  field(:partition_id, 5, proto3_optional: true, type: :string, json_name: "partitionId")
  field(:size_in_mb, 6, proto3_optional: true, type: :int32, json_name: "sizeInMb")
end

defmodule Flintlock.Types.VolumeSource do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VolumeSource",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "container_source",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "containerSource",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "virtiofs_source",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "virtiofsSource",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_container_source",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_virtiofs_source",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:container_source, 1, proto3_optional: true, type: :string, json_name: "containerSource")
  field(:virtiofs_source, 2, proto3_optional: true, type: :string, json_name: "virtiofsSource")
end

defmodule Flintlock.Types.VirtioFSVolumeSource do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VirtioFSVolumeSource",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "path",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "path",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:path, 1, type: :string)
end

defmodule Flintlock.Types.ContainerVolumeSource do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ContainerVolumeSource",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "image",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "image",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:image, 1, type: :string)
end

defmodule Flintlock.Types.MicroVMStatus.MicroVMState do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "MicroVMState",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "PENDING",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "CREATED",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "FAILED",
          number: 2,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "DELETING",
          number: 3,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:PENDING, 0)
  field(:CREATED, 1)
  field(:FAILED, 2)
  field(:DELETING, 3)
end

defmodule Flintlock.Types.MicroVMStatus.VolumesEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VolumesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.VolumeStatus",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: Flintlock.Types.VolumeStatus)
end

defmodule Flintlock.Types.MicroVMStatus.NetworkInterfacesEntry do
  @moduledoc false
  use Protobuf, map: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NetworkInterfacesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.NetworkInterfaceStatus",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: Flintlock.Types.NetworkInterfaceStatus)
end

defmodule Flintlock.Types.MicroVMStatus do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MicroVMStatus",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "state",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".flintlock.types.MicroVMStatus.MicroVMState",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "state",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "volumes",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMStatus.VolumesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "volumes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "kernel_mount",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Mount",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "kernelMount",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "initrd_mount",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Mount",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "initrdMount",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "network_interfaces",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMStatus.NetworkInterfacesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "networkInterfaces",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "retry",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "retry",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "VolumesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.VolumeStatus",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.DescriptorProto{
          name: "NetworkInterfacesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.NetworkInterfaceStatus",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "MicroVMState",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "PENDING",
              number: 0,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "CREATED",
              number: 1,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "FAILED",
              number: 2,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "DELETING",
              number: 3,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          options: nil,
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:state, 1, type: Flintlock.Types.MicroVMStatus.MicroVMState, enum: true)
  field(:volumes, 2, repeated: true, type: Flintlock.Types.MicroVMStatus.VolumesEntry, map: true)
  field(:kernel_mount, 3, type: Flintlock.Types.Mount, json_name: "kernelMount")
  field(:initrd_mount, 4, type: Flintlock.Types.Mount, json_name: "initrdMount")

  field(:network_interfaces, 5,
    repeated: true,
    type: Flintlock.Types.MicroVMStatus.NetworkInterfacesEntry,
    json_name: "networkInterfaces",
    map: true
  )

  field(:retry, 6, type: :int32)
end

defmodule Flintlock.Types.VolumeStatus do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VolumeStatus",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "mount",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.Mount",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "mount",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:mount, 1, type: Flintlock.Types.Mount)
end

defmodule Flintlock.Types.Mount.MountType do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "MountType",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "DEV",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "HOSTPATH",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:DEV, 0)
  field(:HOSTPATH, 1)
end

defmodule Flintlock.Types.Mount do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Mount",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".flintlock.types.Mount.MountType",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "type",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "source",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "source",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "MountType",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "DEV",
              number: 0,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "HOSTPATH",
              number: 1,
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          options: nil,
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:type, 1, type: Flintlock.Types.Mount.MountType, enum: true)
  field(:source, 2, type: :string)
end

defmodule Flintlock.Types.NetworkInterfaceStatus do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NetworkInterfaceStatus",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "host_device_name",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "hostDeviceName",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "index",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "index",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "mac_address",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "macAddress",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:host_device_name, 1, type: :string, json_name: "hostDeviceName")
  field(:index, 2, type: :int32)
  field(:mac_address, 3, type: :string, json_name: "macAddress")
end

defmodule Flintlock.Types.NetworkOverrides do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NetworkOverrides",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "bridge_name",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "bridgeName",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_bridge_name",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:bridge_name, 1, proto3_optional: true, type: :string, json_name: "bridgeName")
end
