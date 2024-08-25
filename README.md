# Lightweight Vue 3 Ruby Build Environment without Webpack

## Overview
A simple Ruby build environment for Vue 3 without Webpack.

This environment uses Ruby scripts to convert Vue 3 Single-File Components (SFC) with template syntax into Vue.js components.

The core script is the `webserver.rb` Ruby script, which starts a Ruby Sinatra web server. By accessing the URL `http://localhost` in the browser, the corresponding conversion scripts are executed.

These scripts convert the Vue 3 components (`.vue` files) into JavaScript (`.js`) files, generate i18n language files in various formats, and minify the generated JavaScript and CSS files.

Once the scripts have completed their work, the finished website is displayed in your browser. With a simple click of the refresh button, changes to the website data or the Vue 3 components are reflected almost immediately.

This setup provides a simple and lightweight Ruby build environment for Vue 3 projects, without the need for a Webpack configuration.

## General Installation
If the build environment is being used for the first time, Ruby (with some gems) and Node.js (with npm) must be installed.

### Install Ruby
Download and install Ruby.
Link to the download page: https://rubyinstaller.org/downloads/

#### Install Ruby Packages
Install the packages required for the Ruby scripts.
Execute the following commands to install the gems on the command line.
The gems will be downloaded and installed automatically.
```
gem install sinatra
gem install nokogiri
gem install optparse
```

### Install Node.js and npm
Download and install Node.js.
The Node.js bundle includes the Node.js runtime and the npm package manager.
Link to the download page: https://nodejs.org/en/download/current/

## Getting Started

Install Ruby (including necessary gems) and Node.js if not already done.

### Structure of Project Folders
A sample folder structure for projects. Project development can be started with this template.
```
-> build-environment (build scripts)
  -> node_modules (npm packages e.g., compiler, minifier)
-> src
  -> website
    -> assets (js, css frameworks)
    -> css (own css files)
    -> js (own js files)
    -> json (json e.g., i18n language)
    -> vue (own components)
```

Copy the template project into your working directory.

### Install npm Packages

Navigate to the `/build-environment` folder and install the required npm packages.

#### Vue 3 SFC Compiler
This package compiles Vue Single File Components (SFCs) into JavaScript.
Navigate to the `/build-environment` folder and execute the following command:
```
npm install @vue/compiler-sfc
```

#### JS Minifier
UglifyJS is a JavaScript parser, minifier, compressor, and beautifier toolkit.
Navigate to the `/build-environment` folder and execute the following command:
```
npm install uglify-js
```

#### CSS Minifier
clean-css is a fast and efficient CSS optimizer for the Node.js platform and any modern browser.
Navigate to the `/build-environment` folder and execute the following command:
```
npm install clean-css
```

### Download JavaScript Frameworks
If you don't want to download the JavaScript frameworks every time you visit the `index.html` page, download the following JavaScript frameworks and save them in the `/website/assets` folder.

Links to the most important frameworks:
- https://unpkg.com/vue@3.4.37/dist/vue.global.js
- https://unpkg.com/vue-i18n@9.13.1/dist/vue-i18n.global.js
- https://unpkg.com/vue-router@4.4.3/dist/vue-router.global.js
- https://unpkg.com/vuex@4.1.0/dist/vuex.global.js

Adjust the paths and the versions according to the frameworks in `index.html`:

```html
<script type="text/javascript" src="assets/vue@3.4.37/vue.global.js"></script>
<script type="text/javascript" src="assets/vue-i18n@9.13.1/vue-i18n.global.js"></script>
<script type="text/javascript" src="assets/vue-router@4.4.3/vue-router.global.js"></script>
<script type="text/javascript" src="assets/vuex@4.1.0/vuex.global.js"></script>
```

### Configuration
The project paths and other settings for the project can be configured using the `/build-environment/config.rb` configuration file.

#### DEBUG
Set Parameter `RELEASE = false` in the `/build-environment/config.rb` configuration file.
When the `RELEASE` parameter is set to `false`, the build environment operates in debug mode. In this mode, the Vue 3 components are converted into files with HTML-based template syntax.

The Vue 3 component is compiled by the Vue 3 built-in compiler when the website is accessed by the client.
The still unoptimized code can be debugged better in the browser.

Attention: Ensure that the Content Security Policy (CSP) of your website is set to `unsafe-eval` to allow the Vue 3 built-in compiler to function properly. Modify the CSP headers or meta tags in your `index.html` file accordingly.

#### RELEASE
Set Parameter `RELEASE = true` in the `/build-environment/config.rb` configuration file.
When the `RELEASE` parameter is set to `true`, the build environment operates in release mode. In this mode, the Vue 3 components are compiled and optimized for production deployment.
This process removes the need for the Vue 3 built-in compiler when the website is accessed by clients.

#### MINIFY FILES
Set Parameter `MINIFY_FILES = true` in the `/build-environment/config.rb` configuration file.
When this parameter is set to `true`, the build process will minify the JavaScript and CSS files to reduce their file size and improve website performance.

The minification process applies to the following folders:
- `/website/css`: All CSS files in this folder will be minified.
- `/website/js`: All JavaScript files in this folder will be minified.
- `/website/vue`: All Vue component files in this folder will be compiled and the resulting JavaScript will be minified.

Minified files will have the `.min` extension appended to their filenames.
The `index.html` file will be updated to reference the minified versions of the CSS and JavaScript files. A new file named `index.min.html` will be generated with these updated references.

## Start Development
The development environment is started using the batch file `start_development.bat`.
This file calls the Ruby script `webserver.rb`.
Start your browser and enter `http://localhost` in the address bar.

## Limitations
This is a rudimentary build environment with some limitations. 

- The setup function, which is a key part of the Vue 3 composition API, is currently not available in this environment. The setup function is created through the Ruby scripts and cannot be used directly in the Vue components.
- No support for built-in and scoped CSS.

Despite these limitations, a lot can be implemented with this build environment. The user can extend and customize this environment as needed to fit their specific requirements.