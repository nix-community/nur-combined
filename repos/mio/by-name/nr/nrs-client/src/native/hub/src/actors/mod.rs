pub mod auth_actor;
pub mod call_actor;
pub mod geo_actor;

use auth_actor::AuthActor;
use call_actor::CallActor;
use geo_actor::GeoActor;

/// Creates and spawns the actors in the async system.
pub async fn create_actors() {
    AuthActor::start();
    CallActor::start();
    GeoActor::start();
}
