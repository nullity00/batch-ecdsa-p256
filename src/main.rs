use std::{ collections::HashMap, env::current_dir, time::{ Instant, Duration } };

use nova_scotia::{
    circom::reader::load_r1cs,
    create_public_params,
    create_recursive_circuit,
    FileLocation,
    C1,
    C2,
    F,
};
use ff::PrimeField;
use nova_snark::{ provider, PublicParams };
use serde::{ Deserialize, Serialize };
use serde_json::json;

#[derive(Serialize, Deserialize)]
#[allow(non_snake_case)]
struct EffSig {
    start_pub_input: [String; 30],
    signatures: Vec<[String; 30]>,
}

pub type G1 = provider::bn256_grumpkin::bn256::Point;
pub type G2 = provider::bn256_grumpkin::grumpkin::Point;
pub type Params = PublicParams<G1, G2, C1<G1>, C2<G2>>;

fn run(per_iteration_count: usize, k: usize, r1cs_path: String, wasm_path: String) -> (Duration, Duration) {
    let root = current_dir().unwrap();
    let circuit_file = root.join(r1cs_path);
    let r1cs = load_r1cs::<G1, G2>(&FileLocation::PathBuf(circuit_file));
    let witness_generator_wasm = root.join(wasm_path);
    let sigs: EffSig = serde_json::from_str(include_str!("data/batch.json")).unwrap();
    let mut start_public_input : Vec<F::<G1>> = Vec::with_capacity(5);

    for i in 0..(5*k) {
        let arr = F::<G1>::from_str_vartime(&sigs.start_pub_input[i]).unwrap();
        start_public_input.push(arr);
    }

    let mut private_inputs = Vec::new();
    let n_sigs = sigs.signatures.len();
    println!("n_sigs: {}", n_sigs);
    let iteration_count = n_sigs / per_iteration_count;
    for i in 0..iteration_count {
        let mut private_input = HashMap::new();
        private_input.insert(
            "signatures".to_string(),
            json!(
                sigs.signatures
                    [i * per_iteration_count..i * per_iteration_count + per_iteration_count]
            )
        );
        private_inputs.push(private_input);
    }
    let pp = create_public_params::<G1, G2>(r1cs.clone());
    println!("Creating a RecursiveSNARK...");
    let start = Instant::now();
    let recursive_snark = create_recursive_circuit::<G1, G2>(
        FileLocation::PathBuf(witness_generator_wasm),
        r1cs,
        private_inputs,
        start_public_input.clone(),
        &pp
    ).unwrap();
    let prover_time = start.elapsed();
    println!("RecursiveSNARK creation took {:?}", start.elapsed());

    let z0_secondary = vec![F::<G2>::zero()];

    // verify the recursive SNARK
    println!("Verifying a RecursiveSNARK...");
    let start = Instant::now();
    let res = recursive_snark.verify(
        &pp,
        iteration_count,
        &start_public_input.clone(),
        &z0_secondary.clone()
    );
    println!("RecursiveSNARK::verify: {:?}, took {:?}", res, start.elapsed());
    let verifier_time = start.elapsed();
    assert!(res.is_ok());
    (prover_time, verifier_time)
}

fn main() {
    let circuit_filepath = format!("src/data/batch_ecdsa.r1cs");
    let witness_gen_filepath = format!("src/data/batch_ecdsa.wasm");
    run(10, 6, circuit_filepath, witness_gen_filepath);
}
