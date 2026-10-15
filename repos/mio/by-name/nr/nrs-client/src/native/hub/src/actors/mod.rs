pub mod call_actor;
pub mod geo_actor;

use call_actor::CallActor;
use geo_actor::GeoActor;

/// Creates and spawns the actors in the async system.
pub async fn create_actors() {
    CallActor::start();
    GeoActor::start();
}
