// Copyright 2014 Google Inc. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')
library pageloader.async.test.webdriver;

import 'dart:async';
import 'dart:io';

import 'package:pageloader/async/webdriver.dart' show WebDriverPageLoader;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:webdriver/io.dart' show Capabilities, WebDriver, createDriver;

import 'src/common.dart' as plt;
import 'src/shared.dart' as shared;

void main() {
  WebDriver driver;

  setUp(() async {
    driver = await _createTestDriver();
    await driver.get(_testPagePath);
    shared.loader = new WebDriverPageLoader(driver, useShadowDom: false);
  });

  tearDown(() async {
    await driver.quit();
    shared.loader = null;
  });

  plt.runTests();
}

String get _testPagePath {
  var testPagePath =
      path.join('test', 'data', 'webdriver_no_shadow_dom_test_page.html');

  testPagePath = path.absolute(testPagePath);
  if (!FileSystemEntity.isFileSync(testPagePath)) {
    throw new Exception('Could not find the test file at "$testPagePath".'
        ' Make sure you are running tests from the root of the project.');
  }
  return path.toUri(testPagePath).toString();
}

Future<WebDriver> _createTestDriver() {
  Map capabilities = Capabilities.chrome;
  Map env = Platform.environment;

  Map chromeOptions = {};

  if (env['CHROMEDRIVER_BINARY'] != null) {
    chromeOptions['binary'] = env['CHROMEDRIVER_BINARY'];
  }

  if (env['CHROMEDRIVER_ARGS'] != null) {
    chromeOptions['args'] = env['CHROMEDRIVER_ARGS'].split(' ');
  }

  if (chromeOptions.isNotEmpty) {
    capabilities['chromeOptions'] = chromeOptions;
  }

  return createDriver(desired: capabilities);
}
