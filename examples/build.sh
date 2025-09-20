rm -rf ./app

#dart pub global activate mason_cli
#mason make omarchy_app -o ./app --project_name app --executable_name app --description "A simple Omarchy application." --author "Your Name" --config_path="\$HOME/.config/\$PROJECT_NAME/config.yaml"

dart ../packages/flutter_omarchy_cli/bin/flutter_omarchy_cli.dart create --project_name app --executable_name app --description "A simple Omarchy application." --author "Your Name"  ./app
