run:
	flutter run --dart-define-from-file=dart_defines.json

run-web:
	flutter run -d chrome --web-port=8088 --dart-define-from-file=dart_defines.json

build-apk:
	flutter build apk --dart-define-from-file=dart_defines.json

clean:
	flutter clean