mod support;

use support::Agent;

#[test]
fn test_headless_agent_simulation() {
    let mut agent = Agent::new("urban_chaos", true);
    let observation = agent.wait_for(|reply| reply["world_ready"] == true);
    assert_eq!(observation["trust_score"], 1.0);
    assert_eq!(observation["wanted_level"], 0);
}

#[test]
fn test_pure_engine_headless_subsystems() {
    use hanga::TrustLedger;
    use hanga::is_action_physically_possible;
    let mut ledger = TrustLedger::default();
    assert!(ledger.is_trusted(1));
    assert_eq!(ledger.score(1), 1.0);
    ledger.penalize(1, 0.4);
    assert!((ledger.score(1) - 0.6).abs() < 1e-5);
    ledger.penalize(1, 0.8);
    assert!(!ledger.is_trusted(1));
    assert!(is_action_physically_possible(
        0.0, 0.0, 0.0, 3.0, 4.0, 0.0, 6.0
    ));
    assert!(!is_action_physically_possible(
        0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 5.0
    ));
}
