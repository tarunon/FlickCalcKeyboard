APP_DIR=${PWD}/App
SOURCES_DIR=${PWD}/Sources
TESTS_DIR=${PWD}/Tests
BUILD_TOOLS_DIR=${PWD}/BuildTools
SWIFTRUN=swift run --package-path ${BUILD_TOOLS_DIR} -c release

init:;	swift package resolve; cd BuildTools; swift package resolve
clean:;	rm -rf ${BUILD_TOOLS_DIR}/.build
lint:
		${SWIFTRUN} swift-format lint -r ${APP_DIR}
		${SWIFTRUN} swift-format lint -r ${SOURCES_DIR}
		${SWIFTRUN} swift-format lint -r ${TESTS_DIR}
format:
		${SWIFTRUN} swift-format format -p -i -r ${APP_DIR}
		${SWIFTRUN} swift-format format -p -i -r ${SOURCES_DIR}
		${SWIFTRUN} swift-format format -p -i -r ${TESTS_DIR}
test:
		xcodebuild -sdk iphonesimulator -configuration Debug -workspace App.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 12' clean test -quiet
license:
		${SWIFTRUN} license-plist --swift-package-path ${PWD}/Package.swift --swift-package-path ${BUILD_TOOLS_DIR}/Package.swift --output-path ${APP_DIR}/App/Settings.bundle
archive:
		expr 1 + `cat ${PWD}/.build_number` > ${PWD}/.build_number
	  BUILD_NUMBER=$$(cat ${PWD}/.build_number) xcodebuild -sdk iphoneos -workspace App.xcworkspace -scheme Prod -configuration Release archive -archivePath ${APP_DIR}/.build/Prod.xcarchive
		open ${APP_DIR}/.build/Prod.xcarchive

