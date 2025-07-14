use std::time::Instant;

use rand::Rng;

uniffi::include_scaffolding!("asleh");

struct TimeoutInterrupt {
    start: Instant,
    timeout: u128,
}

impl TimeoutInterrupt {
    fn new_with_timeout(timeout: u128) -> Self {
        Self {
            start: Instant::now(),
            timeout,
        }
    }
}

impl fend_core::Interrupt for TimeoutInterrupt {
    fn should_interrupt(&self) -> bool {
        Instant::now().duration_since(self.start).as_millis() > self.timeout
    }
}

fn random_u32() -> u32 {
    //3
    let mut rng = rand::rng();
    rng.random()
}

fn create_context(time: u32, timezone_offset: u32) -> fend_core::Context {
    let mut ctx = fend_core::Context::new();
    ctx.set_current_time_v1(time as u64, timezone_offset as i64 * 60);
    ctx.set_random_u32_fn(random_u32);
    ctx
}

pub fn evaluate_fend(input: &str, timeout: u32, time: u32, timezone_offset: u32) -> String {
    let mut ctx = create_context(time, timezone_offset);
    let interrupt = TimeoutInterrupt::new_with_timeout(u128::from(timeout));
    match fend_core::evaluate_with_interrupt(input, &mut ctx, &interrupt) {
        Ok(res) => {
            if res.is_unit_type() {
                return "".to_string();
            }

            res.get_main_result().to_string()
        }
        Err(msg) => format!("Error: {msg}"),
    }
}
