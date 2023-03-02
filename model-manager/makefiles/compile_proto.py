import os, sys

class Converter:
    def _get_python_path():
        SYS_ARGS = sys.argv 
        PROTO_PATH_ARG, PYTHON_PATH_ARG = '--protopath', '--pythonpath'
        PROTO_PATH_VALUE, PYTHON_PATH_VALUE = './proto', './build_proto'
        for i in range(1, len(SYS_ARGS)):
            if (SYS_ARGS[i]==PROTO_PATH_ARG):
                PROTO_PATH_VALUE = SYS_ARGS[i+1]
            elif (SYS_ARGS[i]==PYTHON_PATH_ARG):
                PYTHON_PATH_VALUE = SYS_ARGS[i+1]

        return os.path.abspath(PROTO_PATH_VALUE), os.path.abspath(PYTHON_PATH_VALUE)

    PROTO_PATH, PYTHON_PATH = _get_python_path()


    @staticmethod
    def _compile_protos():
        GENERATE_COMMAND = '{protoc_path} --{language}_out={output_path} {extra} -I{proto_dir} {protofile}'
        input_path, output_path, PROTO_EXTENSION = Converter.PROTO_PATH, Converter.PYTHON_PATH, '.proto'
        protofiles = Converter._get_files_with_suffix(input_path, PROTO_EXTENSION)
        protofiles = Converter._get_output_dirs(protofiles, output_path)
        protoc_path = 'python3 -m grpc_tools.protoc'
        language = 'python'
        extra = '--grpc_python_out={}'.format(output_path)
        for p in protofiles:
            for f, d in p.items():
                command = GENERATE_COMMAND.format(protofile=f,
                                                proto_dir=input_path,
                                                output_path=output_path,
                                                language=language,
                                                extra=extra,
                                                protoc_path=protoc_path)
                os.system(command)


    @staticmethod
    def _get_files_with_suffix(root_dir, suffix):
        files = list()
        for root, dirnames, filenames in os.walk(root_dir):
            for filename in filenames:
                if filename.endswith(suffix):
                    files.append( {os.path.join(root, filename): {'parent_path': root}} )
        return files

    @staticmethod
    def _get_output_dirs(protofiles, output_path):
        for filename in protofiles:
            for key, value in filename.items():
                value['pythonpath'] = os.path.join(output_path, value['parent_path'].removeprefix(Converter.PROTO_PATH))
        return protofiles



Converter._compile_protos()
