APP_DIR=${PWD}/App/
SOURCES_DIR=${PWD}/Sources/
TESTS_DIR=${PWD}/Tests/

init:;	swift package resolve; cd BuildTools; swift package resolve
lint:
		cd BuildTools; swift run -c release --skip-build swift-format lint -r ${APP_DIR}
		cd BuildTools; swift run -c release --skip-build swift-format lint -r ${SOURCES_DIR}
		cd BuildTools; swift run -c release --skip-build swift-format lint -r ${TESTS_DIR}
format:
		cd BuildTools; swift run -c release --skip-build swift-format format -p -i -r ${APP_DIR}
		cd BuildTools; swift run -c release --skip-build swift-format format -p -i -r ${SOURCES_DIR}
		cd BuildTools; swift run -c release --skip-build swift-format format -p -i -r ${TESTS_DIR}
test:
		xcodebuild -sdk iphonesimulator -configuration Debug -workspace App.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 12' clean test -quiet
