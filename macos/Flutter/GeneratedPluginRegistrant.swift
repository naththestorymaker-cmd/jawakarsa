//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_session
import cloud_firestore
import firebase_auth
import firebase_core
import just_audio
import shared_preferences_foundation
<<<<<<< HEAD
import url_launcher_macos
=======
import video_player_avfoundation
>>>>>>> 81ba043 (fitur dan data artikel jawa tengah)

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FLTFirebaseAuthPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAuthPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  JustAudioPlugin.register(with: registry.registrar(forPlugin: "JustAudioPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
<<<<<<< HEAD
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
=======
  VideoPlayerPlugin.register(with: registry.registrar(forPlugin: "VideoPlayerPlugin"))
>>>>>>> 81ba043 (fitur dan data artikel jawa tengah)
}
