![Logo](doc/logo.png)

[![pub package](https://img.shields.io/pub/v/flutter_omarchy.svg)](https://pub.dev/packages/flutter_omarchy)
[![GitHub Stars](https://img.shields.io/github/stars/aloisdeniel/flutter_omarchy.svg)](https://github.com/aloisdeniel/flutter_omarchy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This is the CLI tool for the [Flutter Omarchy](https://githhub.com/aloisdeniel/flutter_omarchy) package, which helps you to create Flutter applications for [Omarchy](https://omarchy.org).

## Install

```bash
flutter pub global activate flutter_omarchy_cli
```

## Usage

### Create 

The create command allows you to create a new Flutter Omarchy application with a set of predefined features.

#### App

The 'app' application template creates a really simple Omarchy application with only the following features:

* Configuration file management: it uses a configuration file to manage the application settings.
* Database: it uses a SQLite database to store the application data.

```bash
fluter_omarchy create app my_app
```bash
