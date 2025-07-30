# [ユーザー向けコマンド]
# --- Android Studio & Emulator Operations ---
#   make boot                  - .envファイルで指定されたエミュレータを起動
#   make run-debug             - デバッグビルドを作成し、エミュレータにインストール、起動
#   make run-release           - リリースビルドを作成し、エミュレータにインストール、起動
#   make clean                 - ビルドディレクトリをクリーン
#   make reset                 - プロジェクトのキャッシュを完全にリセット
#   make open                  - Android Studioでプロジェクトを開く
#
# --- ビルド ---
#   make build-for-testing     - テスト用のビルドを実行
#   make archive               - リリース用のAAB (App Bundle) を作成
#
# --- テスト ---
#   make unit-test             - ユニットテストを実行
#   make ui-test               - UIテスト（インストルメンテーションテスト）を実行
#   make test-all              - 全てのテストを実行
#
# --- Code Style ---
#   make format                - ktlintでコードをフォーマット
#   make format-check          - ktlintでコードのフォーマットをチェック
#   make lint                  - lintを実行

# === 設定 ===
SHELL := /bin/bash
.PHONY: boot run-debug run-release clean reset open build-for-testing archive unit-test ui-test test-all format format-check lint

# .envファイルが存在すれば読み込む
ifneq (,$(wildcard ./.env))
    include .env
endif

# アプリケーションIDをapp/build.gradle.ktsから動的に読み込みます
APP_BUNDLE_ID := $(shell grep "applicationId" app/build.gradle.kts | head -n 1 | sed 's/.*"\(.*\)"/\1/')

# === Android Studio & Emulator Operations ===
boot:
ifndef EMULATOR_NAME
	$(error EMULATOR_NAME is not set. Please set it in your .env file (e.g., EMULATOR_NAME=pixel_6_pro))
endif
	@echo "🚀 Booting emulator: $(EMULATOR_NAME)..."
	@if emulator -list-avds | grep -q "^$(EMULATOR_NAME)$$"; then \
		if adb devices | grep -q "emulator-"; then \
			echo "⚡️ An emulator is already running."; \
		else \
			emulator -avd $(EMULATOR_NAME) & \
			echo "✅ Emulator is booting up in the background."; \
		fi; \
	else \
		echo "❌ Error: Emulator '$(EMULATOR_NAME)' not found."; \
		echo "Available emulators:"; \
		emulator -list-avds; \
		exit 1; \
	fi

run-debug: boot
	@echo "⏳ Waiting for emulator to be fully booted..."
	@timeout=120; \
	while [ "`adb -e shell getprop sys.boot_completed | tr -d '\r\n'`" != "1" ]; do \
		if [ $$timeout -le 0 ]; then \
			echo "\n❌ Error: Timed out waiting for emulator to boot."; \
			exit 1; \
		fi; \
		sleep 2; \
		timeout=$$((timeout-2)); \
	done;
	@echo "✅ Emulator is online."
	@echo "▶️ Building, installing, and launching debug build..."
	./gradlew installDebug
	@echo "🚀 Launching app..."
	@adb -e shell monkey -p $(APP_BUNDLE_ID) -c android.intent.category.LAUNCHER 1
	@echo "✅ App launched."

run-release: boot
	@echo "⏳ Waiting for emulator to be fully booted..."
	@timeout=120; \
	while [ "`adb -e shell getprop sys.boot_completed | tr -d '\r\n'`" != "1" ]; do \
		if [ $$timeout -le 0 ]; then \
			echo "\n❌ Error: Timed out waiting for emulator to boot."; \
			exit 1; \
		fi; \
		sleep 2; \
		timeout=$$((timeout-2)); \
	done;
	@echo "✅ Emulator is online."
	@echo "▶️ Building, installing, and launching release build..."
	./gradlew installRelease
	@echo "🚀 Launching app..."
	@adb -e shell monkey -p $(APP_BUNDLE_ID) -c android.intent.category.LAUNCHER 1
	@echo "✅ App launched."

clean:
	@echo "▶️ Cleaning project..."
	./gradlew clean

reset: clean
	@echo "▶️ Resetting project caches..."
	rm -rf .gradle .idea

open:
	@echo "📖 Opening project in Android Studio..."
	@open -a "Android Studio" .

# === ビルド ===
build-for-testing:
	@echo "▶️ Building app and test APKs..."
	./gradlew assembleDebug assembleDebugAndroidTest

archive:
	@echo "▶️ Building release AAB for publishing..."
	./gradlew bundleRelease

# === テスト ===
unit-test:
	@echo "▶️ Running unit tests..."
	./gradlew testDebugUnitTest

ui-test:
	@echo "▶️ Running UI (instrumented) tests..."
	./gradlew connectedDebugAndroidTest

test-all: unit-test ui-test
	@echo "✅ All tests completed."

# === Code Style ===
format:
	@echo "▶️ Formatting code with ktlint..."
	./gradlew ktlintFormat

format-check:
	@echo "▶️ Checking code format with ktlint..."
	./gradlew ktlintCheck

lint:
	@echo "▶️ Running lint..."
	./gradlew lintDebug
