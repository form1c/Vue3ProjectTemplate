

#####################################
### Configure Script              ###
#####################################

### Compile vue-components for debug or release ###
RELEASE = false
MINIFY_FILES = false

### Sinatra ###
WEBSERVER_PORT = 80

### Project paths ###
PROJECT_FOLDER_PATH = File.dirname(File.expand_path(__FILE__)).sub! "/build-environment", ""
BUILD_SOLUTION_PATH = File.dirname(File.expand_path(__FILE__))

### Page paths ###
WEBSITE_ROOT_PATH = PROJECT_FOLDER_PATH + "/website"
WEBSITE_INDEX_PATH = PROJECT_FOLDER_PATH + "/website/index.html"
WEBSITE_VUE_PATH = PROJECT_FOLDER_PATH + "/website/vue"
WEBSITE_JS_PATH = PROJECT_FOLDER_PATH + "/website/js"
WEBSITE_CSS_PATH = PROJECT_FOLDER_PATH + "/website/css"
