# 06-android-java.zsh — Android SDK and Java toolchain

# Prefer the Android Studio SDK location on macOS. Keep caller-provided values
# intact so CI and project-local shells can override them.
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  : ${ANDROID_HOME:="$HOME/Library/Android/sdk"}
  : ${ANDROID_SDK_ROOT:="$ANDROID_HOME"}
  export ANDROID_HOME ANDROID_SDK_ROOT
fi

# Android and Gradle are most predictable on JDK 17. Prefer Homebrew's JDK 17
# when present, then fall back to java_home's registered JDK 17, then any JDK.
if [[ -z "$JAVA_HOME" ]]; then
  if [[ -x /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/bin/java ]]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
  elif [[ -x /usr/libexec/java_home ]] && /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  elif [[ -x /usr/libexec/java_home ]] && /usr/libexec/java_home >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home)"
  fi
else
  export JAVA_HOME
fi

[[ -n "$JAVA_HOME" && -d "$JAVA_HOME/bin" ]] && path=("$JAVA_HOME/bin" $path)

if [[ -n "$ANDROID_HOME" ]]; then
  [[ -d "$ANDROID_HOME/emulator" ]] && path+=("$ANDROID_HOME/emulator")
  [[ -d "$ANDROID_HOME/platform-tools" ]] && path+=("$ANDROID_HOME/platform-tools")
  [[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]] && path+=("$ANDROID_HOME/cmdline-tools/latest/bin")
fi
