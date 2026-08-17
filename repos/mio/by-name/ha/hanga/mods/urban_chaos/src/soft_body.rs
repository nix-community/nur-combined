pub struct Node {
    pub mass: f32,
    pub position: (f32, f32, f32),
    pub velocity: (f32, f32, f32),
}

pub struct Beam {
    pub node_a: usize,
    pub node_b: usize,
    pub rest_length: f32,
    pub stiffness: f32,
    pub damping: f32,
    pub plastic_yield: f32, // Amount of strain before permanent deformation
}

pub struct SoftBodyState {
    pub nodes: Vec<Node>,
    pub beams: Vec<Beam>,
}

impl SoftBodyState {
    pub fn new() -> Self {
        Self {
            nodes: Vec::new(),
            beams: Vec::new(),
        }
    }

    pub fn tick(&mut self, dt: f32) {
        let mut forces = vec![(0.0, 0.0, 0.0); self.nodes.len()];
        
        for beam in &mut self.beams {
            let n_a = &self.nodes[beam.node_a];
            let n_b = &self.nodes[beam.node_b];
            
            let dx = n_b.position.0 - n_a.position.0;
            let dy = n_b.position.1 - n_a.position.1;
            let dz = n_b.position.2 - n_a.position.2;
            
            let dist = (dx * dx + dy * dy + dz * dz).sqrt().max(0.001);
            let strain = dist - beam.rest_length;
            
            // Plastic deformation
            if strain.abs() > beam.plastic_yield {
                let deformation = (strain.abs() - beam.plastic_yield) * strain.signum() * 0.5;
                beam.rest_length += deformation;
                // Prevent infinite stretching or collapsing to 0
                beam.rest_length = beam.rest_length.clamp(0.01, 10.0); 
            }
            
            let current_strain = dist - beam.rest_length;
            
            let nx = dx / dist;
            let ny = dy / dist;
            let nz = dz / dist;
            
            let dvx = n_b.velocity.0 - n_a.velocity.0;
            let dvy = n_b.velocity.1 - n_a.velocity.1;
            let dvz = n_b.velocity.2 - n_a.velocity.2;
            
            let force_spring = current_strain * beam.stiffness;
            let force_damp = (dvx * nx + dvy * ny + dvz * nz) * beam.damping;
            
            let force_total = force_spring + force_damp;
            
            let fx = force_total * nx;
            let fy = force_total * ny;
            let fz = force_total * nz;
            
            forces[beam.node_a].0 += fx;
            forces[beam.node_a].1 += fy;
            forces[beam.node_a].2 += fz;
            
            forces[beam.node_b].0 -= fx;
            forces[beam.node_b].1 -= fy;
            forces[beam.node_b].2 -= fz;
        }
        
        for (i, node) in self.nodes.iter_mut().enumerate() {
            let f = forces[i];
            // Apply gravity
            let gravity = (0.0, -9.81 * node.mass, 0.0);
            
            let ax = (f.0 + gravity.0) / node.mass;
            let ay = (f.1 + gravity.1) / node.mass;
            let az = (f.2 + gravity.2) / node.mass;
            
            node.velocity.0 += ax * dt;
            node.velocity.1 += ay * dt;
            node.velocity.2 += az * dt;
            
            // Floor collision
            if node.position.1 < 0.0 && node.velocity.1 < 0.0 {
                node.velocity.1 *= -0.5; // bounce/damp
                node.position.1 = 0.0;
                
                // friction
                node.velocity.0 *= 0.9;
                node.velocity.2 *= 0.9;
            }
            
            node.position.0 += node.velocity.0 * dt;
            node.position.1 += node.velocity.1 * dt;
            node.position.2 += node.velocity.2 * dt;
        }
    }
}

#[cfg(kani)]
mod proofs {
    use super::*;

    #[kani::proof]
    #[kani::unwind(2)]
    fn test_plastic_yield_no_nan() {
        let mut state = SoftBodyState::new();
        state.nodes.push(Node {
            mass: kani::any(),
            position: (kani::any(), kani::any(), kani::any()),
            velocity: (kani::any(), kani::any(), kani::any()),
        });
        state.nodes.push(Node {
            mass: kani::any(),
            position: (kani::any(), kani::any(), kani::any()),
            velocity: (kani::any(), kani::any(), kani::any()),
        });
        
        kani::assume(state.nodes[0].mass > 0.1 && state.nodes[0].mass < 1000.0);
        kani::assume(state.nodes[1].mass > 0.1 && state.nodes[1].mass < 1000.0);

        // Limit positions and velocities to avoid initial inf/nan
        for node in &mut state.nodes {
            kani::assume(node.position.0 > -1000.0 && node.position.0 < 1000.0);
            kani::assume(node.position.1 > -1000.0 && node.position.1 < 1000.0);
            kani::assume(node.position.2 > -1000.0 && node.position.2 < 1000.0);
            kani::assume(node.velocity.0 > -1000.0 && node.velocity.0 < 1000.0);
            kani::assume(node.velocity.1 > -1000.0 && node.velocity.1 < 1000.0);
            kani::assume(node.velocity.2 > -1000.0 && node.velocity.2 < 1000.0);
        }

        let mut beam = Beam {
            node_a: 0,
            node_b: 1,
            rest_length: kani::any(),
            stiffness: kani::any(),
            damping: kani::any(),
            plastic_yield: kani::any(),
        };
        
        kani::assume(beam.rest_length > 0.1 && beam.rest_length < 10.0);
        kani::assume(beam.stiffness > 0.0 && beam.stiffness < 1000.0);
        kani::assume(beam.damping > 0.0 && beam.damping < 100.0);
        kani::assume(beam.plastic_yield > 0.0 && beam.plastic_yield < 5.0);
        
        state.beams.push(beam);

        let dt = 0.016; // 60 FPS
        state.tick(dt);

        // Verify no NaNs in positions or velocities
        for node in &state.nodes {
            assert!(!node.position.0.is_nan());
            assert!(!node.position.1.is_nan());
            assert!(!node.position.2.is_nan());
            assert!(!node.velocity.0.is_nan());
            assert!(!node.velocity.1.is_nan());
            assert!(!node.velocity.2.is_nan());
        }
        
        for beam in &state.beams {
            assert!(!beam.rest_length.is_nan());
            assert!(beam.rest_length >= 0.01 && beam.rest_length <= 10.0);
        }
    }
}
