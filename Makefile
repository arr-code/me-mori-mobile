run:
	flutter run --dart-define-from-file=dart_defines.json

build-apk:
	flutter build apk --dart-define-from-file=dart_defines.json

clean:
	flutter clean