use std::cell::RefCell;
use std::io::{self, Write};
use std::rc::Rc;

use pipewire as pw;
use pw::proxy::{Listener, ProxyT};
use libspa as spa;
use spa::pod::{deserialize::PodDeserializer, Value};

const DEFAULT_SINK: &str = "default.audio.sink";
const NODE_NAME: &str = "node.name";

#[derive(Clone, Copy, Debug, PartialEq)]
struct State {
    volume: f32,
    mute: bool,
}

struct App {
    default_name: Option<String>,
    sink_id: Option<u32>,
    state: Option<State>,
}

fn emit(state: State) {
    println!(r#"{{"volume":{},"mute":{}}}"#, state.volume, state.mute);
    let _ = io::stdout().flush();
}

fn props_value(value: &Value) -> (Option<f32>, Option<bool>) {
    let Value::Object(object) = value else { return (None, None) };
    let mut volume = None;
    let mut mute = None;
    for property in &object.properties {
        match property.key {
            // WirePlumber normally exposes channelVolumes (SPA_PROP_channelVolumes)
            // rather than the scalar SPA_PROP_volume. Use the first channel, as
            // wpctl changes all channels together.
            65544 => volume = match &property.value {
                Value::ValueArray(spa::pod::ValueArray::Float(values)) => values.first().copied(),
                Value::Float(value) => Some(*value),
                Value::Double(value) => Some(*value as f32),
                _ => None,
            },
            65539 => volume = match &property.value {
                Value::Float(value) => Some(*value),
                Value::Double(value) => Some(*value as f32),
                _ => volume,
            },
            65540 => mute = match &property.value {
                Value::Bool(value) => Some(*value),
                _ => None,
            },
            _ => {}
        }
    }
    (volume, mute)
}

fn main() -> Result<(), pw::Error> {
    pw::init();
    let loop_ = pw::main_loop::MainLoopRc::new(None)?;
    let context = pw::context::ContextRc::new(&loop_, None)?;
    let core = context.connect_rc(None)?;
    let registry = core.get_registry_rc()?;
    let app = Rc::new(RefCell::new(App { default_name: None, sink_id: None, state: None }));
    let keepalive: Rc<RefCell<Vec<(Box<dyn ProxyT>, Box<dyn Listener>)>>> =
        Rc::new(RefCell::new(Vec::new()));

    let app_for_metadata = app.clone();
    let keepalive_for_metadata = keepalive.clone();
    let registry_weak = registry.downgrade();
    let _registry_listener = registry
        .add_listener_local()
        .global(move |object| {
            let Some(registry) = registry_weak.upgrade() else { return };
            if object.type_ == pw::types::ObjectType::Metadata {
                let metadata: pw::metadata::Metadata = registry.bind(object).unwrap();
                let app = app_for_metadata.clone();
                let listener = metadata.add_listener_local().property(move |_subject, key, _type_, value| {
                    if key == Some(DEFAULT_SINK) {
                        app.borrow_mut().default_name = value.and_then(|value| {
                            serde_json::from_str::<serde_json::Value>(value)
                                .ok()
                                .and_then(|value| value.get("name").and_then(|name| name.as_str()).map(str::to_owned))
                        });
                    }
                    0
                }).register();
                keepalive_for_metadata.borrow_mut().push((Box::new(metadata), Box::new(listener)));
            }
        })
        .register();

    // A second registry listener binds every node and filters in its callbacks.
    let app_for_nodes = app.clone();
    let keepalive_for_nodes = keepalive.clone();
    let registry_weak = registry.downgrade();
    let _nodes = registry
        .add_listener_local()
        .global(move |object| {
            if object.type_ != pw::types::ObjectType::Node { return; }
            let Some(registry) = registry_weak.upgrade() else { return };
            let node: pw::node::Node = registry.bind(object).unwrap();
            let node_id = object.id;
            let app = app_for_nodes.clone();
            let app_for_param = app_for_nodes.clone();
            let listener = node.add_listener_local()
                .info(move |info| {
                    let props = info.props();
                    let Some(props) = props.as_ref() else { return; };
                    let Some(name) = props.get(NODE_NAME) else { return; };
                    let mut app = app.borrow_mut();
                    if app.default_name.as_deref() == Some(name) {
                        app.sink_id = Some(node_id);
                    }
                })
                .param(move |_seq, id, _index, _next, pod| {
                    if id != spa::param::ParamType(spa::sys::SPA_PARAM_Props as u32) { return; }
                    let Some(pod) = pod else { return; };
                    let Ok((_rest, value)) = PodDeserializer::deserialize_any_from(pod.as_bytes()) else { return; };
                    let mut app = app_for_param.borrow_mut();
                    if app.sink_id == Some(node_id) {
                        let (volume, mute) = props_value(&value);
                        let Some(previous) = app.state else {
                            if let (Some(volume), Some(mute)) = (volume, mute) {
                                let state = State { volume, mute };
                                app.state = Some(state);
                                emit(state);
                            }
                            return;
                        };
                        let state = State {
                            volume: volume.unwrap_or(previous.volume),
                            mute: mute.unwrap_or(previous.mute),
                        };
                        if state != previous {
                            app.state = Some(state);
                            emit(state);
                        }
                    }
                })
                .register();
            let props_param = spa::param::ParamType(spa::sys::SPA_PARAM_Props as u32);
            node.subscribe_params(&[props_param]);
            node.enum_params(0, Some(props_param), 0, u32::MAX);
            keepalive_for_nodes.borrow_mut().push((Box::new(node), Box::new(listener)));
        })
        .register();

    loop_.run();
    Ok(())
}
