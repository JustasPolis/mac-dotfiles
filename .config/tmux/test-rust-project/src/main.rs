use test_rust_project::{add, multiply, Calculator};

fn main() {
    let sum = add(2, 3);
    let product = multiply(4, 5);
    println!("Sum: {sum}, Product: {product}");

    let mut calc = Calculator::new();
    let result = calc.compute(10, 20);
    println!("Computed: {result}");
    println!("History: {:?}", calc.history);
}
