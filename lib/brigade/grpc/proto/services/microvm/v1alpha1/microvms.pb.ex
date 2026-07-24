defmodule Microvm.Services.Api.V1alpha1.CreateMicroVMRequest.MetadataEntry do
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
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
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
  field(:value, 2, type: Google.Protobuf.Any)
end

defmodule Microvm.Services.Api.V1alpha1.CreateMicroVMRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CreateMicroVMRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "microvm",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVMSpec",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "microvm",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".microvm.services.api.v1alpha1.CreateMicroVMRequest.MetadataEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
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
              type: :TYPE_MESSAGE,
              type_name: ".google.protobuf.Any",
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
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:microvm, 1, type: Flintlock.Types.MicroVMSpec)

  field(:metadata, 2,
    repeated: true,
    type: Microvm.Services.Api.V1alpha1.CreateMicroVMRequest.MetadataEntry,
    map: true
  )
end

defmodule Microvm.Services.Api.V1alpha1.CreateMicroVMResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CreateMicroVMResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "microvm",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVM",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "microvm",
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

  field(:microvm, 1, type: Flintlock.Types.MicroVM)
end

defmodule Microvm.Services.Api.V1alpha1.DeleteMicroVMRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeleteMicroVMRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "uid",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uid",
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

  field(:uid, 1, type: :string)
end

defmodule Microvm.Services.Api.V1alpha1.GetMicroVMRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetMicroVMRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "uid",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uid",
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

  field(:uid, 1, type: :string)
end

defmodule Microvm.Services.Api.V1alpha1.GetMicroVMResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetMicroVMResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "microvm",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVM",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "microvm",
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

  field(:microvm, 1, type: Flintlock.Types.MicroVM)
end

defmodule Microvm.Services.Api.V1alpha1.ListMicroVMsRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListMicroVMsRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "namespace",
          extendee: nil,
          number: 1,
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
          name: "name",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "name",
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
          name: "_name",
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

  field(:namespace, 1, type: :string)
  field(:name, 2, proto3_optional: true, type: :string)
end

defmodule Microvm.Services.Api.V1alpha1.ListMicroVMsResponse do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListMicroVMsResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "microvm",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVM",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "microvm",
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

  field(:microvm, 1, repeated: true, type: Flintlock.Types.MicroVM)
end

defmodule Microvm.Services.Api.V1alpha1.ListMessage do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "microvm",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".flintlock.types.MicroVM",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "microvm",
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

  field(:microvm, 1, type: Flintlock.Types.MicroVM)
end

defmodule Microvm.Services.Api.V1alpha1.MicroVM.Service do
  @moduledoc false

  use GRPC.Service,
    name: "microvm.services.api.v1alpha1.MicroVM",
    protoc_gen_elixir_version: "0.17.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.FileDescriptorProto{
      name: "services/microvm/v1alpha1/microvms.proto",
      package: "microvm.services.api.v1alpha1",
      dependency: [
        "google/protobuf/empty.proto",
        "google/protobuf/any.proto",
        "types/microvm.proto"
      ],
      message_type: [
        %Google.Protobuf.DescriptorProto{
          name: "CreateMicroVMRequest",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "microvm",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.MicroVMSpec",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "microvm",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "metadata",
              extendee: nil,
              number: 2,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: ".microvm.services.api.v1alpha1.CreateMicroVMRequest.MetadataEntry",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "metadata",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [
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
                  type: :TYPE_MESSAGE,
                  type_name: ".google.protobuf.Any",
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
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.DescriptorProto{
          name: "CreateMicroVMResponse",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "microvm",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.MicroVM",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "microvm",
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
        },
        %Google.Protobuf.DescriptorProto{
          name: "DeleteMicroVMRequest",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "uid",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "uid",
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
        },
        %Google.Protobuf.DescriptorProto{
          name: "GetMicroVMRequest",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "uid",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "uid",
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
        },
        %Google.Protobuf.DescriptorProto{
          name: "GetMicroVMResponse",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "microvm",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.MicroVM",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "microvm",
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
        },
        %Google.Protobuf.DescriptorProto{
          name: "ListMicroVMsRequest",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "namespace",
              extendee: nil,
              number: 1,
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
              name: "name",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: 0,
              json_name: "name",
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
              name: "_name",
              options: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.DescriptorProto{
          name: "ListMicroVMsResponse",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "microvm",
              extendee: nil,
              number: 1,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.MicroVM",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "microvm",
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
        },
        %Google.Protobuf.DescriptorProto{
          name: "ListMessage",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "microvm",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".flintlock.types.MicroVM",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "microvm",
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
      ],
      enum_type: [],
      service: [
        %Google.Protobuf.ServiceDescriptorProto{
          name: "MicroVM",
          method: [
            %Google.Protobuf.MethodDescriptorProto{
              name: "CreateMicroVM",
              input_type: ".microvm.services.api.v1alpha1.CreateMicroVMRequest",
              output_type: ".microvm.services.api.v1alpha1.CreateMicroVMResponse",
              options: nil,
              client_streaming: false,
              server_streaming: false,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.MethodDescriptorProto{
              name: "DeleteMicroVM",
              input_type: ".microvm.services.api.v1alpha1.DeleteMicroVMRequest",
              output_type: ".google.protobuf.Empty",
              options: nil,
              client_streaming: false,
              server_streaming: false,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.MethodDescriptorProto{
              name: "GetMicroVM",
              input_type: ".microvm.services.api.v1alpha1.GetMicroVMRequest",
              output_type: ".microvm.services.api.v1alpha1.GetMicroVMResponse",
              options: nil,
              client_streaming: false,
              server_streaming: false,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.MethodDescriptorProto{
              name: "ListMicroVMs",
              input_type: ".microvm.services.api.v1alpha1.ListMicroVMsRequest",
              output_type: ".microvm.services.api.v1alpha1.ListMicroVMsResponse",
              options: nil,
              client_streaming: false,
              server_streaming: false,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.MethodDescriptorProto{
              name: "ListMicroVMsStream",
              input_type: ".microvm.services.api.v1alpha1.ListMicroVMsRequest",
              output_type: ".microvm.services.api.v1alpha1.ListMessage",
              options: nil,
              client_streaming: false,
              server_streaming: true,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      extension: [],
      options: %Google.Protobuf.FileOptions{
        java_package: nil,
        java_outer_classname: nil,
        optimize_for: :SPEED,
        java_multiple_files: false,
        go_package: "github.com/liquidmetal-dev/flintlock/api/services/microvm/v1alpha1",
        cc_generic_services: false,
        java_generic_services: false,
        py_generic_services: false,
        java_generate_equals_and_hash: nil,
        deprecated: false,
        java_string_check_utf8: false,
        cc_enable_arenas: true,
        objc_class_prefix: nil,
        csharp_namespace: nil,
        swift_prefix: nil,
        php_class_prefix: nil,
        php_namespace: nil,
        php_metadata_namespace: nil,
        ruby_package: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      source_code_info: %Google.Protobuf.SourceCodeInfo{
        location: [
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [],
            span: [0, 0, 57, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: ~c"\f",
            span: [0, 0, 18],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [2],
            span: [8, 0, 38],
            leading_comments:
              " Brigade codegen input. Wire-identical to flintlock v0.11.0\n api/services/microvm/v1alpha1/microvms.proto (pristine copy under proto/vendor/).\n The grpc-gateway REST/openapiv2 annotations (google.api.http, openapiv2_swagger)\n have been removed: they affect ONLY the HTTP/JSON gateway, never the gRPC wire\n format, and Brigade is gRPC-only day 1. Service/message/field definitions are\n byte-for-byte the upstream contract, so generated stubs match flintlock exactly.\n",
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [3, 0],
            span: [10, 0, 37],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [3, 1],
            span: [11, 0, 35],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [3, 2],
            span: [12, 0, 29],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: ~c"\b",
            span: [14, 0, 89],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: ~c"\b\v",
            span: [14, 0, 89],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0],
            span: [17, 0, 23, 1],
            leading_comments:
              " MicroVM providers a service to create and manage the lifecycle of microvms.\n",
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 1],
            span: [17, 8, 15],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 0],
            span: [18, 2, 74],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 0, 1],
            span: [18, 6, 19],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 0, 2],
            span: [18, 20, 40],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 0, 3],
            span: [18, 51, 72],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 1],
            span: [19, 2, 74],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 1, 1],
            span: [19, 6, 19],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 1, 2],
            span: [19, 20, 40],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 1, 3],
            span: [19, 51, 72],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 2],
            span: [20, 2, 65],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 2, 1],
            span: [20, 6, 16],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 2, 2],
            span: [20, 17, 34],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 2, 3],
            span: [20, 45, 63],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 3],
            span: [21, 2, 71],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 3, 1],
            span: [21, 6, 18],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 3, 2],
            span: [21, 19, 38],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 3, 3],
            span: [21, 49, 69],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 4],
            span: [22, 2, 75],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 4, 1],
            span: [22, 6, 24],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 4, 2],
            span: [22, 25, 44],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 4, 6],
            span: [22, 55, 61],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [6, 0, 2, 4, 3],
            span: [22, 62, 73],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0],
            span: [25, 0, 28, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 1],
            span: [25, 8, 28],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 0],
            span: [26, 2, 42],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 0, 6],
            span: [26, 2, 29],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 0, 1],
            span: [26, 30, 37],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 0, 3],
            span: [26, 40, 41],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 1],
            span: [27, 2, 48],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 1, 6],
            span: [27, 2, 34],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 1, 1],
            span: ~c"\e#+",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 0, 2, 1, 3],
            span: ~c"\e./",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1],
            span: [30, 0, 32, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1, 1],
            span: [30, 8, 29],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1, 2, 0],
            span: [31, 2, 38],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1, 2, 0, 6],
            span: [31, 2, 25],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1, 2, 0, 1],
            span: [31, 26, 33],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 1, 2, 0, 3],
            span: [31, 36, 37],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2],
            span: [34, 0, 36, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2, 1],
            span: [34, 8, 28],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2, 2, 0],
            span: [35, 2, 17],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2, 2, 0, 5],
            span: [35, 2, 8],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2, 2, 0, 1],
            span: ~c"#\t\f",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 2, 2, 0, 3],
            span: [35, 15, 16],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3],
            span: [38, 0, 40, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3, 1],
            span: [38, 8, 25],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3, 2, 0],
            span: [39, 2, 17],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3, 2, 0, 5],
            span: [39, 2, 8],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3, 2, 0, 1],
            span: ~c"'\t\f",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 3, 2, 0, 3],
            span: [39, 15, 16],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4],
            span: [42, 0, 44, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4, 1],
            span: [42, 8, 26],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4, 2, 0],
            span: [43, 2, 38],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4, 2, 0, 6],
            span: [43, 2, 25],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4, 2, 0, 1],
            span: [43, 26, 33],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 4, 2, 0, 3],
            span: ~c"+$%",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5],
            span: [46, 0, 49, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 1],
            span: ~c".\b\e",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 0],
            span: [47, 2, 23],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 0, 5],
            span: [47, 2, 8],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 0, 1],
            span: [47, 9, 18],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 0, 3],
            span: [47, 21, 22],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 1],
            span: [48, 2, 27],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 1, 4],
            span: [48, 2, 10],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 1, 5],
            span: [48, 11, 17],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 1, 1],
            span: [48, 18, 22],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 5, 2, 1, 3],
            span: [48, 25, 26],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6],
            span: [51, 0, 53, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 1],
            span: [51, 8, 28],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 2, 0],
            span: [52, 2, 47],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 2, 0, 4],
            span: [52, 2, 10],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 2, 0, 6],
            span: ~c"4\v\"",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 2, 0, 1],
            span: ~c"4#*",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 6, 2, 0, 3],
            span: ~c"4-.",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7],
            span: [55, 0, 57, 1],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7, 1],
            span: [55, 8, 19],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7, 2, 0],
            span: [56, 2, 38],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7, 2, 0, 6],
            span: [56, 2, 25],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7, 2, 0, 1],
            span: [56, 26, 33],
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          },
          %Google.Protobuf.SourceCodeInfo.Location{
            path: [4, 7, 2, 0, 3],
            span: ~c"8$%",
            leading_comments: nil,
            trailing_comments: nil,
            leading_detached_comments: [],
            __unknown_fields__: [],
            __protobuf__: true
          }
        ],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      public_dependency: [],
      weak_dependency: [],
      syntax: "proto3",
      edition: nil,
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  rpc(
    :CreateMicroVM,
    Microvm.Services.Api.V1alpha1.CreateMicroVMRequest,
    Microvm.Services.Api.V1alpha1.CreateMicroVMResponse
  )

  rpc(:DeleteMicroVM, Microvm.Services.Api.V1alpha1.DeleteMicroVMRequest, Google.Protobuf.Empty)

  rpc(
    :GetMicroVM,
    Microvm.Services.Api.V1alpha1.GetMicroVMRequest,
    Microvm.Services.Api.V1alpha1.GetMicroVMResponse
  )

  rpc(
    :ListMicroVMs,
    Microvm.Services.Api.V1alpha1.ListMicroVMsRequest,
    Microvm.Services.Api.V1alpha1.ListMicroVMsResponse
  )

  rpc(
    :ListMicroVMsStream,
    Microvm.Services.Api.V1alpha1.ListMicroVMsRequest,
    stream(Microvm.Services.Api.V1alpha1.ListMessage)
  )
end

defmodule Microvm.Services.Api.V1alpha1.MicroVM.Stub do
  @moduledoc false

  use GRPC.Stub, service: Microvm.Services.Api.V1alpha1.MicroVM.Service
end
