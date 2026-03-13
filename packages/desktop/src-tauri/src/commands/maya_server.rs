use tauri::State;

use crate::maya_server::manager::MayaServerManager;
use crate::types::MayaServerInfo;

#[tauri::command]
pub fn maya_server_info(manager: State<MayaServerManager>) -> MayaServerInfo {
    let mut state = manager.inner.lock().expect("maya server mutex poisoned");
    MayaServerManager::snapshot_locked(&mut state)
}

// start/stop are handled by engine lifecycle
