
#dart pub global activate mason_cli
#mason make omarchy_app -o ./app --project_name app --executable_name app --description "A simple Omarchy application." --author "Your Name" --config_path="\$HOME/.config/\$PROJECT_NAME/config.yaml"

rm -rf ./app
dart ../packages/flutter_omarchy_cli/bin/flutter_omarchy.dart create app --project_name app --executable_name app --description "A simple Omarchy application." --author "Aloïs Deniel"

rm -rf ./app_advanced
dart ../packages/flutter_omarchy_cli/bin/flutter_omarchy.dart create app_advanced --project_name app_advanced --executable_name app_advanced --description "A simple Omarchy application which uses Riverpod and Drift." --author "Aloïs Deniel" --riverpod --drift 
