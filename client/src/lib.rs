use wasm_bindgen::prelude::*;
use web_sys::{MediaStreamTrack, RtcPeerConnection, RtcStatsReport};
use serde::{Serialize, Deserialize};
use js_sys::Reflect;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

#[derive(Serialize, Deserialize)]
pub struct DetectionResult {
    pub is_virtual: bool,
    pub confidence: f32,
    pub reasons: Vec<String>,
}

#[wasm_bindgen]
pub struct AIDetector {
}

#[wasm_bindgen]
impl AIDetector {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        AIDetector {}
    }

    pub fn analyze_capabilities(&self, track: &MediaStreamTrack) -> Result<JsValue, JsValue> {
        let mut reasons = Vec::new();
        let mut score = 0.0;

        log("Analyzing track capabilities via Reflect...");

        // Since web-sys might have issues with MediaTrackCapabilities gating,
        // we use Reflect to access the method and the resulting object.

        let get_capabilities = Reflect::get(track, &JsValue::from_str("getCapabilities"))?;
        if get_capabilities.is_function() {
            let caps_js = js_sys::Function::from(get_capabilities).call0(track)?;

            let hardware_props = vec![
                "exposureMode",
                "whiteBalanceMode",
                "focusMode",
                "brightness",
                "contrast",
                "saturation",
                "sharpness",
            ];

            let mut missing_count = 0;
            for prop in &hardware_props {
                if !Reflect::has(&caps_js, &JsValue::from_str(prop))? {
                    missing_count += 1;
                }
            }

            if missing_count >= hardware_props.len() - 1 {
                score += 0.5;
                reasons.push(format!("Missing {}/{} hardware-specific capabilities", missing_count, hardware_props.len()));
            }
        } else {
            reasons.push("getCapabilities() not supported on this track".to_string());
        }

        let result = DetectionResult {
            is_virtual: score >= 0.5,
            confidence: score,
            reasons,
        };

        Ok(serde_wasm_bindgen::to_value(&result)?)
    }

    pub async fn analyze_stats(&self, pc: &RtcPeerConnection) -> Result<JsValue, JsValue> {
        let stats_promise = pc.get_stats();
        let stats_value = wasm_bindgen_futures::JsFuture::from(stats_promise).await?;
        let stats: RtcStatsReport = stats_value.dyn_into()?;

        let mut reasons = Vec::new();
        let mut score = 0.0;

        let stats_iter = js_sys::try_iter(&stats)?.ok_or("Stats report not iterable")?;
        for item in stats_iter {
            let item = item?;
            let value = Reflect::get(&item, &JsValue::from(1))?;
            let type_val = Reflect::get(&value, &JsValue::from_str("type"))?;

            if type_val == "inbound-rtp" {
                let jitter = Reflect::get(&value, &JsValue::from_str("jitter"))?;
                if let Some(j) = jitter.as_f64() {
                    if j == 0.0 {
                        score += 0.3;
                        reasons.push("Zero jitter detected".to_string());
                    }
                }
            }
        }

        let result = DetectionResult {
            is_virtual: score >= 0.5,
            confidence: score,
            reasons,
        };

        Ok(serde_wasm_bindgen::to_value(&result)?)
    }
}
