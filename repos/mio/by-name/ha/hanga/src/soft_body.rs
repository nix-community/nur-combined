//! BeamNG-style node–beam soft body for rideables.
//!
//! Nodes carry mass; beams are massless springs with plastic deform and break
//! strength. Each kit part owns a lattice (chassis box or pressure tire). Kit
//! `beams` brace named parts together; the first part stays pinned so the
//! avian collider origin does not drift. The host integrates every frame and
//! on crash; the mod only names the graph and the steel (`stiffness`).

use crate::vehicle::VehiclePartSpec;

const TIRE_RING: usize = 8;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SoftNodeKind {
    Chassis,
    Hub,
    Tire,
}

#[derive(Clone, Debug, PartialEq)]
pub struct SoftNode {
    pub mass: f32,
    pub position: [f32; 3],
    pub velocity: [f32; 3],
    pub pinned: bool,
    pub kind: SoftNodeKind,
}

#[derive(Clone, Debug, PartialEq)]
pub struct SoftBeam {
    pub a: usize,
    pub b: usize,
    pub rest_length: f32,
    pub spring: f32,
    pub damp: f32,
    /// Stretch past this permanently changes rest length (BeamNG beamDeform).
    pub deform: f32,
    /// Stretch past this snaps the beam (BeamNG beamStrength).
    pub strength: f32,
    pub broken: bool,
    /// Soft in compression, stiff in extension (tire radial beams).
    pub anisotropic: bool,
}

#[derive(Clone, Debug, PartialEq)]
pub struct SoftPart {
    pub name: String,
    pub part_index: usize,
    pub tire: bool,
    pub node_indices: Vec<usize>,
    pub rest_center: [f32; 3],
    pub rest_extents: [f32; 3],
}

#[derive(Clone, Debug, PartialEq)]
pub struct SoftPartPose {
    pub translation: [f32; 3],
    pub scale: [f32; 3],
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct SoftBody {
    pub nodes: Vec<SoftNode>,
    pub beams: Vec<SoftBeam>,
    pub parts: Vec<SoftPart>,
    /// Tire cavity pressure (N toward rim from hub).
    pub tire_pressure: f32,
}

impl SoftBody {
    /// Build a full soft body: chassis lattices, pressure tires, kit braces.
    pub fn from_kit(
        parts: &[VehiclePartSpec],
        beams: &[(String, String)],
        tires: &[String],
        kit_stiffness: i32,
    ) -> Self {
        let stiff = kit_stiffness.clamp(0, 100) as f32 / 100.0;
        let chassis_spring = 1_200.0 + stiff * 6_800.0;
        let chassis_damp = 14.0 + stiff * 55.0;
        let chassis_deform = 0.035 + (1.0 - stiff) * 0.22;
        let chassis_strength = 0.22 + stiff * 0.55;
        let tire_spring = 280.0 + stiff * 420.0;
        let tire_damp = 6.0 + stiff * 18.0;
        let pressure = 420.0 + stiff * 280.0;

        let mut body = SoftBody {
            nodes: Vec::new(),
            beams: Vec::new(),
            parts: Vec::new(),
            tire_pressure: pressure,
        };
        if parts.is_empty() {
            return body;
        }

        for (part_index, part) in parts.iter().enumerate() {
            let is_tire = tires.iter().any(|t| t == &part.name);
            if is_tire {
                body.add_tire_part(part_index, part, tire_spring, tire_damp, stiff);
            } else {
                body.add_chassis_part(
                    part_index,
                    part,
                    part_index == 0,
                    chassis_spring,
                    chassis_damp,
                    chassis_deform,
                    chassis_strength,
                );
            }
        }

        // Kit beams brace every part named a to every part named b.
        for (from, to) in beams {
            let left: Vec<usize> = body
                .parts
                .iter()
                .filter(|p| p.name == *from)
                .map(|p| p.part_index)
                .collect();
            let right: Vec<usize> = body
                .parts
                .iter()
                .filter(|p| p.name == *to)
                .map(|p| p.part_index)
                .collect();
            for &a in &left {
                for &b in &right {
                    if a == b {
                        continue;
                    }
                    body.brace_parts(
                        a,
                        b,
                        chassis_spring * 0.85,
                        chassis_damp,
                        chassis_deform,
                        chassis_strength,
                    );
                }
            }
        }

        // Missing kit beams: star-brace every free part to the pin so nothing
        // floats. Internal lattice edges alone do not count as braces.
        let has_inter_part = body.beams.iter().any(|beam| {
            if beam.anisotropic {
                return false;
            }
            match (body.part_of_node(beam.a), body.part_of_node(beam.b)) {
                (Some(i), Some(j)) => i != j,
                _ => false,
            }
        });
        if !has_inter_part && body.parts.len() > 1 {
            for p in 1..body.parts.len() {
                body.brace_parts(
                    0,
                    p,
                    chassis_spring * 0.75,
                    chassis_damp,
                    chassis_deform,
                    chassis_strength,
                );
            }
        }

        // Ensure every tire is linked to the hull even if the kit only named
        // one wheel brace — otherwise duplicate wheels float.
        for part in body.parts.clone() {
            if !part.tire || part.part_index == 0 {
                continue;
            }
            let linked = body.beams.iter().any(|beam| {
                if beam.broken || beam.anisotropic {
                    return false;
                }
                let a_part = body.part_of_node(beam.a);
                let b_part = body.part_of_node(beam.b);
                matches!((a_part, b_part), (Some(0), Some(i)) | (Some(i), Some(0)) if i == part.part_index)
            });
            if !linked {
                body.brace_parts(
                    0,
                    part.part_index,
                    chassis_spring * 0.75,
                    chassis_damp,
                    chassis_deform,
                    chassis_strength,
                );
            }
        }

        body
    }

    /// Back-compat wrapper: no tire list → treat nothing as a pressure wheel.
    pub fn from_parts(
        parts: &[VehiclePartSpec],
        beams: &[(String, String)],
        kit_stiffness: i32,
    ) -> Self {
        Self::from_kit(parts, beams, &[], kit_stiffness)
    }

    fn add_chassis_part(
        &mut self,
        part_index: usize,
        part: &VehiclePartSpec,
        pinned: bool,
        spring: f32,
        damp: f32,
        deform_frac: f32,
        strength_frac: f32,
    ) {
        let half = [part.size[0] * 0.5, part.size[1] * 0.5, part.size[2] * 0.5];
        let vol = (part.size[0] * part.size[1] * part.size[2]).max(0.05);
        // Larger parts get a denser lattice (BeamNG chassis mesh, not one node).
        let (nx, ny, nz) = lattice_res(part);
        let count = nx * ny * nz;
        let mass = ((vol * 220.0) / count as f32).clamp(4.0, 180.0);
        let mut indices = Vec::with_capacity(count);
        for iz in 0..nz {
            for iy in 0..ny {
                for ix in 0..nx {
                    let fx = if nx == 1 {
                        0.0
                    } else {
                        ix as f32 / (nx - 1) as f32 * 2.0 - 1.0
                    };
                    let fy = if ny == 1 {
                        0.0
                    } else {
                        iy as f32 / (ny - 1) as f32 * 2.0 - 1.0
                    };
                    let fz = if nz == 1 {
                        0.0
                    } else {
                        iz as f32 / (nz - 1) as f32 * 2.0 - 1.0
                    };
                    let pos = [
                        part.offset[0] + fx * half[0],
                        part.offset[1] + fy * half[1],
                        part.offset[2] + fz * half[2],
                    ];
                    indices.push(self.nodes.len());
                    self.nodes.push(SoftNode {
                        mass,
                        position: pos,
                        velocity: [0.0, 0.0, 0.0],
                        pinned,
                        kind: SoftNodeKind::Chassis,
                    });
                }
            }
        }
        // Grid edges + face diagonals so boxes stay rigid (BeamNG cross-brace).
        let idx = |x: usize, y: usize, z: usize| indices[z * ny * nx + y * nx + x];
        for iz in 0..nz {
            for iy in 0..ny {
                for ix in 0..nx {
                    let i = idx(ix, iy, iz);
                    if ix + 1 < nx {
                        self.push_beam(i, idx(ix + 1, iy, iz), spring, damp, deform_frac, strength_frac, false);
                    }
                    if iy + 1 < ny {
                        self.push_beam(i, idx(ix, iy + 1, iz), spring, damp, deform_frac, strength_frac, false);
                    }
                    if iz + 1 < nz {
                        self.push_beam(i, idx(ix, iy, iz + 1), spring, damp, deform_frac, strength_frac, false);
                    }
                    // Face diagonals on +X / +Y / +Z faces from this cell.
                    if ix + 1 < nx && iy + 1 < ny {
                        self.push_beam(i, idx(ix + 1, iy + 1, iz), spring * 0.9, damp, deform_frac, strength_frac, false);
                    }
                    if ix + 1 < nx && iz + 1 < nz {
                        self.push_beam(i, idx(ix + 1, iy, iz + 1), spring * 0.9, damp, deform_frac, strength_frac, false);
                    }
                    if iy + 1 < ny && iz + 1 < nz {
                        self.push_beam(i, idx(ix, iy + 1, iz + 1), spring * 0.9, damp, deform_frac, strength_frac, false);
                    }
                }
            }
        }
        self.parts.push(SoftPart {
            name: part.name.clone(),
            part_index,
            tire: false,
            node_indices: indices,
            rest_center: part.offset,
            rest_extents: half,
        });
    }

    fn add_tire_part(
        &mut self,
        part_index: usize,
        part: &VehiclePartSpec,
        spring: f32,
        damp: f32,
        stiff: f32,
    ) {
        let thin = thin_axis(part.size);
        let (axis_u, axis_v) = match thin {
            0 => (1, 2),
            1 => (0, 2),
            _ => (0, 1),
        };
        let radius = part.size[axis_u].max(part.size[axis_v]) * 0.5;
        let hub_mass = 28.0 + stiff * 20.0;
        let rim_mass = ((12.0 + stiff * 8.0) / TIRE_RING as f32).clamp(1.5, 8.0);
        let hub = self.nodes.len();
        self.nodes.push(SoftNode {
            mass: hub_mass,
            position: part.offset,
            velocity: [0.0, 0.0, 0.0],
            pinned: false,
            kind: SoftNodeKind::Hub,
        });
        let deform = 0.12 + (1.0 - stiff) * 0.2;
        let strength = 0.55 + stiff * 0.35;
        let mut indices = vec![hub];
        for i in 0..TIRE_RING {
            let ang = (i as f32) * std::f32::consts::TAU / TIRE_RING as f32;
            let mut pos = part.offset;
            pos[axis_u] += ang.cos() * radius;
            pos[axis_v] += ang.sin() * radius;
            let rim = self.nodes.len();
            indices.push(rim);
            self.nodes.push(SoftNode {
                mass: rim_mass,
                position: pos,
                velocity: [0.0, 0.0, 0.0],
                pinned: false,
                kind: SoftNodeKind::Tire,
            });
            // Radial: soft compression / stiff extension (pressure-wheel style).
            self.push_beam(hub, rim, spring, damp, deform, strength, true);
        }
        for i in 0..TIRE_RING {
            let a = indices[1 + i];
            let b = indices[1 + ((i + 1) % TIRE_RING)];
            self.push_beam(a, b, spring * 1.4, damp, deform * 0.8, strength, false);
            // Cross reinforcement for lateral stiffness.
            let c = indices[1 + ((i + 2) % TIRE_RING)];
            self.push_beam(a, c, spring * 0.7, damp, deform, strength, false);
        }
        let half = [part.size[0] * 0.5, part.size[1] * 0.5, part.size[2] * 0.5];
        self.parts.push(SoftPart {
            name: part.name.clone(),
            part_index,
            tire: true,
            node_indices: indices,
            rest_center: part.offset,
            rest_extents: half,
        });
    }

    fn brace_parts(
        &mut self,
        a_part: usize,
        b_part: usize,
        spring: f32,
        damp: f32,
        deform_frac: f32,
        strength_frac: f32,
    ) {
        let (a_nodes, a_tire) = match self.parts.iter().find(|p| p.part_index == a_part) {
            Some(p) => (p.node_indices.clone(), p.tire),
            None => return,
        };
        let (b_nodes, b_tire) = match self.parts.iter().find(|p| p.part_index == b_part) {
            Some(p) => (p.node_indices.clone(), p.tire),
            None => return,
        };
        if a_nodes.is_empty() || b_nodes.is_empty() {
            return;
        }
        // Link nearest node pairs (and centroids) so braces triangulate.
        let ca = centroid(&self.nodes, &a_nodes);
        let cb = centroid(&self.nodes, &b_nodes);
        let a0 = nearest_node(&self.nodes, &a_nodes, cb);
        let b0 = nearest_node(&self.nodes, &b_nodes, ca);
        self.push_beam(a0, b0, spring, damp, deform_frac, strength_frac, false);
        // Second brace for torsion resistance.
        let a1 = farthest_node(&self.nodes, &a_nodes, self.nodes[a0].position);
        let b1 = farthest_node(&self.nodes, &b_nodes, self.nodes[b0].position);
        if a1 != a0 || b1 != b0 {
            self.push_beam(a1, b1, spring * 0.85, damp, deform_frac, strength_frac, false);
        }
        // Hub preferred when bracing a tire.
        if a_tire {
            self.push_beam(a_nodes[0], b0, spring, damp, deform_frac, strength_frac, false);
        }
        if b_tire {
            self.push_beam(a0, b_nodes[0], spring, damp, deform_frac, strength_frac, false);
        }
    }

    fn push_beam(
        &mut self,
        a: usize,
        b: usize,
        spring: f32,
        damp: f32,
        deform_frac: f32,
        strength_frac: f32,
        anisotropic: bool,
    ) {
        if a == b || a >= self.nodes.len() || b >= self.nodes.len() {
            return;
        }
        let rest = dist(self.nodes[a].position, self.nodes[b].position).max(0.04);
        self.beams.push(SoftBeam {
            a,
            b,
            rest_length: rest,
            spring,
            damp,
            deform: deform_frac * rest.max(0.15),
            strength: strength_frac * rest.max(0.2),
            broken: false,
            anisotropic,
        });
    }

    fn part_of_node(&self, node: usize) -> Option<usize> {
        self.parts
            .iter()
            .find(|p| p.node_indices.contains(&node))
            .map(|p| p.part_index)
    }

    /// Tire pressure + ground load (BeamNG pressure-wheel style).
    pub fn apply_tire_load(&mut self, grounded: bool, speed: f32, kit_stiffness: i32) {
        let stiff = kit_stiffness.clamp(0, 100) as f32 / 100.0;
        let pressure = self.tire_pressure;
        for part in &self.parts {
            if !part.tire || part.node_indices.len() < 2 {
                continue;
            }
            let hub = part.node_indices[0];
            let hub_pos = self.nodes[hub].position;
            for &rim in &part.node_indices[1..] {
                let p = self.nodes[rim].position;
                let dx = p[0] - hub_pos[0];
                let dy = p[1] - hub_pos[1];
                let dz = p[2] - hub_pos[2];
                let len = (dx * dx + dy * dy + dz * dz).sqrt().max(1e-4);
                let inv = 1.0 / self.nodes[rim].mass.max(1e-3);
                // Outward cavity pressure.
                self.nodes[rim].velocity[0] += (dx / len) * pressure * inv * 0.002;
                self.nodes[rim].velocity[1] += (dy / len) * pressure * inv * 0.002;
                self.nodes[rim].velocity[2] += (dz / len) * pressure * inv * 0.002;
            }
        }
        if !grounded {
            return;
        }
        let load = (80.0 + speed.max(0.0) * 3.5) * (1.1 - stiff * 0.45);
        for node in &mut self.nodes {
            if node.kind != SoftNodeKind::Tire || node.pinned {
                continue;
            }
            // Ground reaction on the lower half of the tire ring.
            if node.position[1] < -0.15 {
                let inv = 1.0 / node.mass.max(1e-3);
                node.velocity[1] += load * inv * 0.02;
            }
        }
    }

    /// One integration step in the vehicle's local frame (no world gravity).
    pub fn tick(&mut self, dt: f32) {
        let dt = dt.clamp(0.0, 0.05);
        if dt <= 0.0 || self.nodes.is_empty() {
            return;
        }
        let n = self.nodes.len();
        let mut force = vec![[0.0f32; 3]; n];

        for beam in &mut self.beams {
            if beam.broken || beam.a >= n || beam.b >= n || beam.a == beam.b {
                continue;
            }
            let a = &self.nodes[beam.a];
            let b = &self.nodes[beam.b];
            let dx = b.position[0] - a.position[0];
            let dy = b.position[1] - a.position[1];
            let dz = b.position[2] - a.position[2];
            let dist = (dx * dx + dy * dy + dz * dz).sqrt().max(1e-4);
            let mut stretch = dist - beam.rest_length;

            // Plastic yield (BeamNG beamDeform).
            if stretch < -beam.deform {
                let give = (stretch + beam.deform) * 0.5 * dt;
                beam.rest_length = (beam.rest_length + give).clamp(0.04, 14.0);
                stretch = dist - beam.rest_length;
            } else if stretch > beam.deform {
                let give = (stretch - beam.deform) * 0.18 * dt;
                beam.rest_length = (beam.rest_length + give).clamp(0.04, 14.0);
                stretch = dist - beam.rest_length;
            }

            // Snap (BeamNG beamStrength).
            if stretch.abs() > beam.strength {
                beam.broken = true;
                continue;
            }

            let spring = beam_effective_spring(beam, stretch);

            let ux = dx / dist;
            let uy = dy / dist;
            let uz = dz / dist;
            let rel = (b.velocity[0] - a.velocity[0]) * ux
                + (b.velocity[1] - a.velocity[1]) * uy
                + (b.velocity[2] - a.velocity[2]) * uz;
            let mag = stretch * spring + rel * beam.damp;
            let fx = ux * mag;
            let fy = uy * mag;
            let fz = uz * mag;
            force[beam.a][0] += fx;
            force[beam.a][1] += fy;
            force[beam.a][2] += fz;
            force[beam.b][0] -= fx;
            force[beam.b][1] -= fy;
            force[beam.b][2] -= fz;
        }

        for (i, node) in self.nodes.iter_mut().enumerate() {
            if node.pinned {
                node.velocity = [0.0, 0.0, 0.0];
                continue;
            }
            let inv = 1.0 / node.mass.max(1e-3);
            node.velocity[0] += force[i][0] * inv * dt;
            node.velocity[1] += force[i][1] * inv * dt;
            node.velocity[2] += force[i][2] * inv * dt;
            node.velocity[0] *= 0.991;
            node.velocity[1] *= 0.991;
            node.velocity[2] *= 0.991;
            node.position[0] += node.velocity[0] * dt;
            node.position[1] += node.velocity[1] * dt;
            node.position[2] += node.velocity[2] * dt;
        }
    }

    /// Inject crash energy: kick free nodes, soften and break beams.
    pub fn impact(&mut self, dir: [f32; 3], severity: i32, kit_stiffness: i32) {
        let severity = severity.clamp(0, 100) as f32;
        if severity < 1.0 {
            return;
        }
        let stiff = kit_stiffness.clamp(0, 100) as f32 / 100.0;
        let len = (dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2]).sqrt();
        let (ux, uy, uz) = if len < 1e-4 {
            (0.0, 0.0, 1.0)
        } else {
            (dir[0] / len, dir[1] / len, dir[2] / len)
        };
        let kick = severity * (0.14 + (1.0 - stiff) * 0.26);
        for node in &mut self.nodes {
            if node.pinned {
                continue;
            }
            // Nodes facing the impact take more energy.
            let align = (node.position[0] * ux + node.position[1] * uy + node.position[2] * uz)
                .max(0.15);
            let scale = kick * align / node.mass.max(1.0);
            node.velocity[0] += ux * scale * 48.0;
            node.velocity[1] += uy * scale * 48.0 + severity * 0.025;
            node.velocity[2] += uz * scale * 48.0;
        }
        let soften = (severity / 100.0) * (1.0 - stiff) * 0.4;
        for beam in &mut self.beams {
            if beam.broken {
                continue;
            }
            beam.rest_length = (beam.rest_length * (1.0 - soften * 0.85)).clamp(0.04, 14.0);
            beam.deform = (beam.deform * (1.0 - soften * 0.5)).max(0.015);
            beam.strength = (beam.strength * (1.0 - soften * 0.35)).max(0.04);
            // Hard hits snap the softest braces on the impact side.
            if severity >= 50.0 && !beam.anisotropic {
                let mid = [
                    (self.nodes[beam.a].position[0] + self.nodes[beam.b].position[0]) * 0.5,
                    (self.nodes[beam.a].position[1] + self.nodes[beam.b].position[1]) * 0.5,
                    (self.nodes[beam.a].position[2] + self.nodes[beam.b].position[2]) * 0.5,
                ];
                let align = mid[0] * ux + mid[1] * uy + mid[2] * uz;
                if align > 0.2 && beam.spring < 2_500.0 && severity >= 70.0 {
                    beam.broken = true;
                }
            }
        }
    }

    pub fn part_pose(&self, part_index: usize) -> Option<SoftPartPose> {
        let part = self.parts.iter().find(|p| p.part_index == part_index)?;
        if part.node_indices.is_empty() {
            return None;
        }
        let translation = centroid(&self.nodes, &part.node_indices);
        let (min, max) = aabb(&self.nodes, &part.node_indices);
        let scale = [
            scale_axis(max[0] - min[0], part.rest_extents[0]),
            scale_axis(max[1] - min[1], part.rest_extents[1]),
            scale_axis(max[2] - min[2], part.rest_extents[2]),
        ];
        Some(SoftPartPose {
            translation,
            scale,
        })
    }

    pub fn position_of(&self, name: &str) -> Option<[f32; 3]> {
        let part = self.parts.iter().find(|p| p.name == name)?;
        Some(centroid(&self.nodes, &part.node_indices))
    }

    pub fn broken_beam_count(&self) -> usize {
        self.beams.iter().filter(|b| b.broken).count()
    }
}

fn lattice_res(part: &VehiclePartSpec) -> (usize, usize, usize) {
    let vol = part.size[0] * part.size[1] * part.size[2];
    if vol > 2.5 || part.name == "hull" || part.name == "body" {
        (
            denser(part.size[0]),
            denser(part.size[1]).max(2),
            denser(part.size[2]),
        )
    } else {
        (2, 2, 2)
    }
}

fn denser(len: f32) -> usize {
    if len > 2.5 {
        3
    } else {
        2
    }
}

fn thin_axis(size: [f32; 3]) -> usize {
    if size[0] <= size[1] && size[0] <= size[2] {
        0
    } else if size[1] <= size[2] {
        1
    } else {
        2
    }
}

fn dist(a: [f32; 3], b: [f32; 3]) -> f32 {
    let dx = b[0] - a[0];
    let dy = b[1] - a[1];
    let dz = b[2] - a[2];
    (dx * dx + dy * dy + dz * dz).sqrt()
}

fn centroid(nodes: &[SoftNode], indices: &[usize]) -> [f32; 3] {
    let mut c = [0.0; 3];
    let mut w = 0.0;
    for &i in indices {
        let n = &nodes[i];
        c[0] += n.position[0] * n.mass;
        c[1] += n.position[1] * n.mass;
        c[2] += n.position[2] * n.mass;
        w += n.mass;
    }
    let inv = 1.0 / w.max(1e-3);
    [c[0] * inv, c[1] * inv, c[2] * inv]
}

fn aabb(nodes: &[SoftNode], indices: &[usize]) -> ([f32; 3], [f32; 3]) {
    let mut min = [f32::MAX; 3];
    let mut max = [f32::MIN; 3];
    for &i in indices {
        let p = nodes[i].position;
        for a in 0..3 {
            min[a] = min[a].min(p[a]);
            max[a] = max[a].max(p[a]);
        }
    }
    (min, max)
}

/// Visual scale from deformed span vs rest half-extent (clamped).
pub fn soft_part_scale_axis(span: f32, rest_half: f32) -> f32 {
    let rest = (rest_half * 2.0).max(0.05);
    (span / rest).clamp(0.35, 1.45)
}

fn scale_axis(span: f32, rest_half: f32) -> f32 {
    soft_part_scale_axis(span, rest_half)
}

/// BeamNG anisotropic radials: soft compression, stiff extension.
pub fn beam_effective_spring(beam: &SoftBeam, stretch: f32) -> f32 {
    if beam.anisotropic && stretch < 0.0 {
        beam.spring * 0.35
    } else if beam.anisotropic {
        beam.spring * 1.6
    } else {
        beam.spring
    }
}

fn nearest_node(nodes: &[SoftNode], indices: &[usize], target: [f32; 3]) -> usize {
    let mut best = indices[0];
    let mut best_d = f32::MAX;
    for &i in indices {
        let d = dist(nodes[i].position, target);
        if d < best_d {
            best_d = d;
            best = i;
        }
    }
    best
}

fn farthest_node(nodes: &[SoftNode], indices: &[usize], target: [f32; 3]) -> usize {
    let mut best = indices[0];
    let mut best_d = -1.0;
    for &i in indices {
        let d = dist(nodes[i].position, target);
        if d > best_d {
            best_d = d;
            best = i;
        }
    }
    best
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_car() -> SoftBody {
        let parts = vec![
            VehiclePartSpec {
                name: "hull".into(),
                size: [1.8, 0.5, 3.8],
                offset: [0.0, -0.2, 0.0],
                rgb: [0.8, 0.2, 0.1],
            },
            VehiclePartSpec {
                name: "cabin".into(),
                size: [1.5, 0.5, 1.7],
                offset: [0.0, 0.3, 0.4],
                rgb: [0.2, 0.2, 0.25],
            },
            VehiclePartSpec {
                name: "lamp".into(),
                size: [0.2, 0.1, 0.1],
                offset: [0.6, 0.0, -1.8],
                rgb: [1.0, 1.0, 0.7],
            },
            VehiclePartSpec {
                name: "wheel".into(),
                size: [0.28, 0.42, 0.42],
                offset: [-0.8, -0.4, -1.1],
                rgb: [0.1, 0.1, 0.1],
            },
            VehiclePartSpec {
                name: "wheel".into(),
                size: [0.28, 0.42, 0.42],
                offset: [0.8, -0.4, -1.1],
                rgb: [0.1, 0.1, 0.1],
            },
        ];
        SoftBody::from_kit(
            &parts,
            &[
                ("hull".into(), "cabin".into()),
                ("cabin".into(), "lamp".into()),
                ("hull".into(), "wheel".into()),
                ("hull".into(), "lamp".into()),
            ],
            &["wheel".into()],
            32,
        )
    }

    fn two_node_body(broken: bool) -> SoftBody {
        SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 1.0,
                    position: [0.0, 0.0, 0.0],
                    velocity: [1.0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 2.0,
                    position: [1.0, 0.0, 0.0],
                    velocity: [-0.5, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: 1.0,
                spring: 100.0,
                damp: 0.0,
                deform: 0.5,
                strength: 10.0,
                broken,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        }
    }

    #[test]
    fn hull_lattice_is_pinned_and_tires_are_pressure_wheels() {
        let body = sample_car();
        assert!(body
            .nodes
            .iter()
            .any(|n| n.pinned && n.kind == SoftNodeKind::Chassis));
        assert_eq!(body.parts.len(), 5);
        let tires: Vec<_> = body.parts.iter().filter(|p| p.tire).collect();
        assert_eq!(tires.len(), 2);
        assert_eq!(tires[0].node_indices.len(), 1 + TIRE_RING);
        assert!(body.beams.iter().any(|b| b.anisotropic));
        assert!(
            body.nodes.len() > 20,
            "chassis lattice + tires, not one node/part"
        );
        assert!(body.nodes.iter().all(|n| n.mass > 0.0));
        assert!(body.tire_pressure > 0.0);
    }

    #[test]
    fn hull_is_denser_than_small_parts() {
        let body = sample_car();
        let hull = body.parts.iter().find(|p| p.name == "hull").unwrap();
        let lamp = body.parts.iter().find(|p| p.name == "lamp").unwrap();
        assert!(hull.node_indices.len() > lamp.node_indices.len());
    }

    #[test]
    fn empty_kit_is_empty_body() {
        let body = SoftBody::from_kit(&[], &[], &[], 50);
        assert!(body.nodes.is_empty());
        assert!(body.beams.is_empty());
        assert!(body.parts.is_empty());
    }

    #[test]
    fn duplicate_wheels_each_get_their_own_nodes() {
        let body = sample_car();
        let w0 = body.parts.iter().find(|p| p.part_index == 3).unwrap();
        let w1 = body.parts.iter().find(|p| p.part_index == 4).unwrap();
        assert_ne!(w0.node_indices[0], w1.node_indices[0]);
        let c0 = centroid(&body.nodes, &w0.node_indices);
        let c1 = centroid(&body.nodes, &w1.node_indices);
        assert!((c0[0] - c1[0]).abs() > 0.5);
    }

    #[test]
    fn kit_wheel_brace_links_every_duplicate_wheel() {
        let body = sample_car();
        for wheel in body.parts.iter().filter(|p| p.tire) {
            let linked = body.beams.iter().any(|beam| {
                if beam.broken || beam.anisotropic {
                    return false;
                }
                matches!(
                    (body.part_of_node(beam.a), body.part_of_node(beam.b)),
                    (Some(0), Some(i)) | (Some(i), Some(0)) if i == wheel.part_index
                )
            });
            assert!(linked, "wheel {} must brace to hull", wheel.part_index);
        }
    }

    #[test]
    fn stiffer_kit_uses_stiffer_chassis_springs() {
        let soft = SoftBody::from_parts(
            &[VehiclePartSpec {
                name: "hull".into(),
                size: [1.0, 1.0, 1.0],
                offset: [0.0, 0.0, 0.0],
                rgb: [1.0, 0.0, 0.0],
            }],
            &[],
            10,
        );
        let hard = SoftBody::from_parts(
            &[VehiclePartSpec {
                name: "hull".into(),
                size: [1.0, 1.0, 1.0],
                offset: [0.0, 0.0, 0.0],
                rgb: [1.0, 0.0, 0.0],
            }],
            &[],
            90,
        );
        let soft_spring = soft.beams.iter().map(|b| b.spring).fold(0.0_f32, f32::max);
        let hard_spring = hard.beams.iter().map(|b| b.spring).fold(0.0_f32, f32::max);
        assert!(hard_spring > soft_spring);
    }

    #[test]
    fn impact_moves_free_nodes_and_shortens_beams() {
        let mut body = sample_car();
        let before: f32 = body
            .beams
            .iter()
            .filter(|b| !b.broken)
            .map(|b| b.rest_length)
            .sum();
        let pinned_rest: Vec<[f32; 3]> = body
            .nodes
            .iter()
            .filter(|n| n.pinned)
            .map(|n| n.position)
            .collect();
        let cabin = body.part_pose(1).unwrap().translation;
        body.impact([0.0, 0.0, 1.0], 80, 32);
        let after_hit: f32 = body
            .beams
            .iter()
            .filter(|b| !b.broken)
            .map(|b| b.rest_length)
            .sum();
        assert!(after_hit < before, "crash permanently softens the lattice");
        for _ in 0..45 {
            body.tick(1.0 / 60.0);
        }
        let after = body.part_pose(1).unwrap().translation;
        let moved = (after[0] - cabin[0]).abs()
            + (after[1] - cabin[1]).abs()
            + (after[2] - cabin[2]).abs();
        assert!(moved > 1e-3, "cabin should deform after a hard hit");
        let pinned_now: Vec<[f32; 3]> = body
            .nodes
            .iter()
            .filter(|n| n.pinned)
            .map(|n| n.position)
            .collect();
        assert_eq!(pinned_rest, pinned_now, "pinned hull lattice must not drift");
        assert!(body.nodes.iter().all(|n| {
            n.position[0].is_finite()
                && n.position[1].is_finite()
                && n.position[2].is_finite()
                && n.velocity[0].is_finite()
                && n.velocity[1].is_finite()
                && n.velocity[2].is_finite()
        }));
    }

    #[test]
    fn zero_severity_impact_is_a_noop() {
        let mut body = sample_car();
        let before = body.clone();
        body.impact([1.0, 0.0, 0.0], 0, 32);
        assert_eq!(body, before);
    }

    #[test]
    fn hard_impact_can_break_beams() {
        let mut body = sample_car();
        body.impact([0.0, 0.0, 1.0], 100, 10);
        for _ in 0..30 {
            body.tick(1.0 / 60.0);
        }
        assert!(
            body.broken_beam_count() > 0,
            "BeamNG strength should snap some braces"
        );
    }

    #[test]
    fn broken_beam_does_not_pull_nodes() {
        let mut live = two_node_body(false);
        let mut dead = two_node_body(true);
        // Stretch so the live spring actually pulls.
        live.nodes[1].position[0] = 1.5;
        dead.nodes[1].position[0] = 1.5;
        live.tick(1.0 / 60.0);
        dead.tick(1.0 / 60.0);
        // Live spring changes relative velocity; broken only applies numerical damp.
        assert!((live.nodes[0].velocity[0] - dead.nodes[0].velocity[0]).abs() > 1e-4);
        assert!((dead.nodes[0].velocity[0] - 1.0 * 0.991).abs() < 1e-5);
        assert!((dead.nodes[1].velocity[0] - (-0.5) * 0.991).abs() < 1e-5);
    }

    #[test]
    fn overstretched_beam_snaps() {
        let mut body = two_node_body(false);
        body.beams[0].strength = 0.05;
        body.nodes[1].position = [2.0, 0.0, 0.0];
        body.tick(1.0 / 60.0);
        assert!(body.beams[0].broken);
        assert_eq!(body.broken_beam_count(), 1);
    }

    #[test]
    fn tire_load_moves_grounded_rim_nodes() {
        let mut body = sample_car();
        let rim = body.parts[3].node_indices[1];
        let before = body.nodes[rim].position;
        for _ in 0..40 {
            body.apply_tire_load(true, 25.0, 32);
            body.tick(1.0 / 60.0);
        }
        let after = body.nodes[rim].position;
        let moved = (after[0] - before[0]).abs()
            + (after[1] - before[1]).abs()
            + (after[2] - before[2]).abs();
        assert!(moved > 1e-4, "pressure + ground load should flex the tire");
    }

    #[test]
    fn airborne_tire_load_skips_ground_reaction() {
        let mut grounded = sample_car();
        let mut air = sample_car();
        let rim = grounded.parts[3].node_indices[1];
        // Put a rim node below the ground threshold.
        grounded.nodes[rim].position[1] = -0.5;
        air.nodes[rim].position[1] = -0.5;
        grounded.nodes[rim].velocity = [0.0, 0.0, 0.0];
        air.nodes[rim].velocity = [0.0, 0.0, 0.0];
        grounded.apply_tire_load(true, 20.0, 32);
        air.apply_tire_load(false, 20.0, 32);
        assert!(grounded.nodes[rim].velocity[1] > air.nodes[rim].velocity[1]);
    }

    #[test]
    fn missing_beams_still_get_star_braces() {
        let parts = vec![
            VehiclePartSpec {
                name: "hull".into(),
                size: [1.0, 1.0, 1.0],
                offset: [0.0, 0.0, 0.0],
                rgb: [1.0, 0.0, 0.0],
            },
            VehiclePartSpec {
                name: "wing".into(),
                size: [0.4, 0.2, 0.8],
                offset: [1.0, 0.0, 0.0],
                rgb: [0.0, 1.0, 0.0],
            },
        ];
        let body = SoftBody::from_kit(&parts, &[], &[], 50);
        assert!(body.beams.len() > 8, "internal lattice + star brace");
        assert!(body.beams.iter().any(|b| {
            matches!(
                (body.part_of_node(b.a), body.part_of_node(b.b)),
                (Some(0), Some(1)) | (Some(1), Some(0))
            )
        }));
    }

    #[test]
    fn part_pose_unknown_index_is_none() {
        let body = sample_car();
        assert!(body.part_pose(99).is_none());
    }

    #[test]
    fn part_pose_scale_stays_clamped() {
        let mut body = sample_car();
        for node in &mut body.nodes {
            if !node.pinned {
                node.position[0] *= 8.0;
                node.position[1] *= 8.0;
                node.position[2] *= 8.0;
            }
        }
        let pose = body.part_pose(1).unwrap();
        assert!(pose.scale.iter().all(|&s| (0.35..=1.45).contains(&s)));
    }

    #[test]
    fn non_positive_dt_is_a_noop() {
        let mut body = two_node_body(false);
        let before = body.clone();
        body.tick(0.0);
        body.tick(-1.0);
        assert_eq!(body, before);
    }

    #[test]
    fn anisotropic_radial_is_soft_in_compression() {
        let beam = SoftBeam {
            a: 0,
            b: 1,
            rest_length: 1.0,
            spring: 100.0,
            damp: 0.0,
            deform: 0.2,
            strength: 1.0,
            broken: false,
            anisotropic: true,
        };
        assert!((beam_effective_spring(&beam, -0.1) - 35.0).abs() < 1e-5);
        assert!((beam_effective_spring(&beam, 0.1) - 160.0).abs() < 1e-5);
        let plain = SoftBeam {
            anisotropic: false,
            ..beam.clone()
        };
        assert!((beam_effective_spring(&plain, -0.1) - 100.0).abs() < 1e-5);
    }

    #[test]
    fn kani_replay_soft_part_scale_axis_bounds() {
        assert!((soft_part_scale_axis(1.0, 0.5) - 1.0).abs() < 1e-5);
        assert!((soft_part_scale_axis(0.0, 0.5) - 0.35).abs() < 1e-5);
        assert!((soft_part_scale_axis(10.0, 0.5) - 1.45).abs() < 1e-5);
        assert!((soft_part_scale_axis(1.0, 0.0) - 1.45).abs() < 1e-5);
    }

    #[test]
    fn kani_replay_beam_effective_spring() {
        let beam = SoftBeam {
            a: 0,
            b: 1,
            rest_length: 1.0,
            spring: 200.0,
            damp: 0.0,
            deform: 0.1,
            strength: 1.0,
            broken: false,
            anisotropic: true,
        };
        assert!(beam_effective_spring(&beam, -1.0) < beam_effective_spring(&beam, 1.0));
        assert!((beam_effective_spring(&beam, -1.0) - 70.0).abs() < 1e-5);
        assert!((beam_effective_spring(&beam, 1.0) - 320.0).abs() < 1e-5);
    }

    #[test]
    fn kani_replay_momentum_approx_conserved() {
        let mut body = two_node_body(false);
        body.beams[0].damp = 0.0;
        let px0 = body.nodes[0].mass * body.nodes[0].velocity[0]
            + body.nodes[1].mass * body.nodes[1].velocity[0];
        body.tick(1.0 / 60.0);
        let px1 = body.nodes[0].mass * body.nodes[0].velocity[0]
            + body.nodes[1].mass * body.nodes[1].velocity[0];
        assert!((px0 * 0.991 - px1).abs() < 1e-3);
    }

    #[test]
    fn kani_replay_pinned_nodes_immobile() {
        let mut body = SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 10.0,
                    position: [0.0, 0.0, 0.0],
                    velocity: [5.0, 5.0, 5.0],
                    pinned: true,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 1.0,
                    position: [1.0, 0.0, 0.0],
                    velocity: [0.0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: 1.0,
                spring: 500.0,
                damp: 0.0,
                deform: 0.5,
                strength: 10.0,
                broken: false,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        body.tick(1.0 / 60.0);
        assert_eq!(body.nodes[0].position, [0.0, 0.0, 0.0]);
        assert_eq!(body.nodes[0].velocity, [0.0, 0.0, 0.0]);
    }

    #[test]
    fn kani_replay_rest_length_stays_clamped() {
        let mut body = two_node_body(false);
        body.beams[0].rest_length = 0.5;
        body.beams[0].deform = 0.01;
        body.nodes[1].position = [0.05, 0.0, 0.0];
        for _ in 0..20 {
            body.tick(1.0 / 60.0);
        }
        assert!(body.beams[0].rest_length >= 0.04);
        assert!(body.beams[0].rest_length <= 14.0);
    }
}

#[cfg(kani)]
mod kani_verification {
    use super::*;

    fn assume_finite_node(n: &SoftNode) {
        kani::assume(n.mass.is_finite() && n.mass > 0.0 && n.mass < 1_000.0);
        kani::assume(n.position[0].is_finite() && n.position[0].abs() < 100.0);
        kani::assume(n.position[1].is_finite() && n.position[1].abs() < 100.0);
        kani::assume(n.position[2].is_finite() && n.position[2].abs() < 100.0);
        kani::assume(n.velocity[0].is_finite() && n.velocity[0].abs() < 100.0);
        kani::assume(n.velocity[1].is_finite() && n.velocity[1].abs() < 100.0);
        kani::assume(n.velocity[2].is_finite() && n.velocity[2].abs() < 100.0);
    }

    #[kani::proof]
    fn verify_softbody_momentum_conservation() {
        let dt: f32 = 0.016;
        let mut body = SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 1.0,
                    position: [kani::any(), kani::any(), kani::any()],
                    velocity: [kani::any(), kani::any(), kani::any()],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 2.0,
                    position: [kani::any(), kani::any(), kani::any()],
                    velocity: [kani::any(), kani::any(), kani::any()],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: kani::any(),
                spring: kani::any(),
                damp: 0.0,
                deform: kani::any(),
                strength: 1_000.0,
                broken: false,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        for n in &body.nodes {
            assume_finite_node(n);
        }
        kani::assume(
            body.beams[0].rest_length.is_finite()
                && body.beams[0].rest_length > 0.1
                && body.beams[0].rest_length < 100.0,
        );
        kani::assume(
            body.beams[0].spring.is_finite()
                && body.beams[0].spring >= 0.0
                && body.beams[0].spring < 1000.0,
        );
        kani::assume(
            body.beams[0].deform.is_finite()
                && body.beams[0].deform > 0.0
                && body.beams[0].deform < 100.0,
        );

        let initial_px = body.nodes[0].mass * body.nodes[0].velocity[0]
            + body.nodes[1].mass * body.nodes[1].velocity[0];
        let initial_py = body.nodes[0].mass * body.nodes[0].velocity[1]
            + body.nodes[1].mass * body.nodes[1].velocity[1];
        let initial_pz = body.nodes[0].mass * body.nodes[0].velocity[2]
            + body.nodes[1].mass * body.nodes[1].velocity[2];

        body.tick(dt);

        let final_px = body.nodes[0].mass * body.nodes[0].velocity[0]
            + body.nodes[1].mass * body.nodes[1].velocity[0];
        let final_py = body.nodes[0].mass * body.nodes[0].velocity[1]
            + body.nodes[1].mass * body.nodes[1].velocity[1];
        let final_pz = body.nodes[0].mass * body.nodes[0].velocity[2]
            + body.nodes[1].mass * body.nodes[1].velocity[2];

        kani::assert(
            (initial_px * 0.991 - final_px).abs() < 1.0,
            "X momentum approx conserved",
        );
        kani::assert(
            (initial_py * 0.991 - final_py).abs() < 1.0,
            "Y momentum approx conserved",
        );
        kani::assert(
            (initial_pz * 0.991 - final_pz).abs() < 1.0,
            "Z momentum approx conserved",
        );
    }

    #[kani::proof]
    fn verify_pinned_nodes_immobile() {
        let px: f32 = kani::any();
        let py: f32 = kani::any();
        let pz: f32 = kani::any();
        kani::assume(px.is_finite() && py.is_finite() && pz.is_finite());
        kani::assume(px.abs() < 50.0 && py.abs() < 50.0 && pz.abs() < 50.0);
        let mut body = SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 10.0,
                    position: [px, py, pz],
                    velocity: [kani::any(), kani::any(), kani::any()],
                    pinned: true,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 1.0,
                    position: [px + 1.0, py, pz],
                    velocity: [0.0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: 1.0,
                spring: 500.0,
                damp: 0.0,
                deform: 0.5,
                strength: 10.0,
                broken: false,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        assume_finite_node(&body.nodes[0]);
        assume_finite_node(&body.nodes[1]);
        body.tick(0.016);
        kani::assert(
            (body.nodes[0].position[0] - px).abs() < 1e-5
                && (body.nodes[0].position[1] - py).abs() < 1e-5
                && (body.nodes[0].position[2] - pz).abs() < 1e-5,
            "pinned node position frozen",
        );
        kani::assert(
            body.nodes[0].velocity[0] == 0.0
                && body.nodes[0].velocity[1] == 0.0
                && body.nodes[0].velocity[2] == 0.0,
            "pinned node velocity cleared",
        );
    }

    #[kani::proof]
    fn verify_broken_beam_applies_no_force() {
        let v0: f32 = kani::any();
        let v1: f32 = kani::any();
        kani::assume(v0.is_finite() && v0.abs() < 50.0);
        kani::assume(v1.is_finite() && v1.abs() < 50.0);
        let mut body = SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 1.0,
                    position: [0.0, 0.0, 0.0],
                    velocity: [v0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 2.0,
                    position: [1.0, 0.0, 0.0],
                    velocity: [v1, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: 1.0,
                spring: 1_000.0,
                damp: 0.0,
                deform: 0.5,
                strength: 10.0,
                broken: true,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        body.tick(0.016);
        kani::assert(
            (body.nodes[0].velocity[0] - v0 * 0.991).abs() < 1e-4,
            "broken beam leaves only numerical damping on node 0",
        );
        kani::assert(
            (body.nodes[1].velocity[0] - v1 * 0.991).abs() < 1e-4,
            "broken beam leaves only numerical damping on node 1",
        );
    }

    #[kani::proof]
    fn verify_soft_part_scale_axis_bounds() {
        let span: f32 = kani::any();
        let rest_half: f32 = kani::any();
        kani::assume(span.is_finite() && rest_half.is_finite());
        kani::assume(span.abs() < 1e6 && rest_half.abs() < 1e6);
        let s = soft_part_scale_axis(span, rest_half);
        kani::assert(s.is_finite(), "scale is finite");
        kani::assert(s >= 0.35 && s <= 1.45, "scale stays in visual clamp");
    }

    #[kani::proof]
    fn verify_beam_effective_spring_anisotropy() {
        let spring: f32 = kani::any();
        let stretch: f32 = kani::any();
        kani::assume(spring.is_finite() && spring >= 0.0 && spring < 1e4);
        kani::assume(stretch.is_finite() && stretch.abs() < 1e4);
        let beam = SoftBeam {
            a: 0,
            b: 1,
            rest_length: 1.0,
            spring,
            damp: 0.0,
            deform: 0.1,
            strength: 1.0,
            broken: false,
            anisotropic: true,
        };
        let soft = beam_effective_spring(&beam, -stretch.abs() - 0.01);
        let stiff = beam_effective_spring(&beam, stretch.abs() + 0.01);
        kani::assert(soft <= stiff + 1e-4, "compression spring <= extension spring");
        kani::assert(
            (soft - spring * 0.35).abs() < 1e-3,
            "compression uses 0.35x spring",
        );
        kani::assert(
            (stiff - spring * 1.6).abs() < 1e-3,
            "extension uses 1.6x spring",
        );
    }

    #[kani::proof]
    fn verify_zero_severity_impact_noop() {
        let mut body = SoftBody {
            nodes: vec![SoftNode {
                mass: 1.0,
                position: [0.0, 0.0, 0.0],
                velocity: [1.0, 2.0, 3.0],
                pinned: false,
                kind: SoftNodeKind::Chassis,
            }],
            beams: vec![SoftBeam {
                a: 0,
                b: 0,
                rest_length: 1.0,
                spring: 100.0,
                damp: 0.0,
                deform: 0.1,
                strength: 1.0,
                broken: false,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 100.0,
        };
        let before = body.clone();
        let severity: i32 = kani::any();
        kani::assume(severity <= 0);
        body.impact([kani::any(), kani::any(), kani::any()], severity, 50);
        kani::assert(body == before, "severity <= 0 leaves the body untouched");
    }

    #[kani::proof]
    fn verify_rest_length_clamped_after_tick() {
        let mut body = SoftBody {
            nodes: vec![
                SoftNode {
                    mass: 1.0,
                    position: [0.0, 0.0, 0.0],
                    velocity: [0.0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
                SoftNode {
                    mass: 1.0,
                    position: [kani::any(), 0.0, 0.0],
                    velocity: [0.0, 0.0, 0.0],
                    pinned: false,
                    kind: SoftNodeKind::Chassis,
                },
            ],
            beams: vec![SoftBeam {
                a: 0,
                b: 1,
                rest_length: kani::any(),
                spring: 200.0,
                damp: 0.0,
                deform: 0.01,
                strength: 100.0,
                broken: false,
                anisotropic: false,
            }],
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        kani::assume(body.nodes[1].position[0].is_finite());
        kani::assume(body.nodes[1].position[0] > 0.05 && body.nodes[1].position[0] < 20.0);
        kani::assume(body.beams[0].rest_length.is_finite());
        kani::assume(body.beams[0].rest_length > 0.05 && body.beams[0].rest_length < 20.0);
        body.tick(0.016);
        kani::assert(
            body.beams[0].rest_length >= 0.04 && body.beams[0].rest_length <= 14.0,
            "plastic yield keeps rest length in clamp",
        );
    }

    #[kani::proof]
    fn verify_non_positive_dt_noop() {
        let mut body = SoftBody {
            nodes: vec![SoftNode {
                mass: 1.0,
                position: [0.0, 0.0, 0.0],
                velocity: [1.0, 0.0, 0.0],
                pinned: false,
                kind: SoftNodeKind::Chassis,
            }],
            beams: Vec::new(),
            parts: Vec::new(),
            tire_pressure: 0.0,
        };
        let before = body.clone();
        let dt: f32 = kani::any();
        kani::assume(dt.is_finite() && dt <= 0.0);
        body.tick(dt);
        kani::assert(body == before, "dt <= 0 leaves the body untouched");
    }
}
