pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

pub fn multiply(a: i32, b: i32) -> i32 {
    a * b
}

pub struct Calculator {
    pub history: Vec<i32>,
}

impl Calculator {
    pub fn new() -> Self {
        Self {
            history: Vec::new(),
        }
    }

    pub fn compute(&mut self, a: i32, b: i32) -> i32 {
        let result = add(a, b);
        self.history.push(result);
        result
    }
}
