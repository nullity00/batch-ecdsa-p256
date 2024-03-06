import { p256 } from '@noble/curves/p256';
import { SignatureType } from '@noble/curves/abstract/weierstrass';
import crypto from "crypto";
import fs from "fs";

function bigint_to_array(n: number, k: number, x: bigint) {
    let mod: bigint = 1n;
    for (var idx = 0; idx < n; idx++) {
      mod = mod * 2n;
    }
  
    let ret: bigint[] = [];
    var x_temp: bigint = x;
    for (var idx = 0; idx < k; idx++) {
      ret.push(x_temp % mod);
      x_temp = x_temp / mod;
    }
    return ret;
}

const main = () => {
    /* 
    * This is a script for generating sample signatures for the sig_ecdsa circuits.
    * Useful for generating batches of random signatures when needed.
    */
    const numSignatures = 10;
    const privKey: bigint = 88549154299169935420064281163296845505587953610183896504176354567359434168161n;
    const pubKey = p256.ProjectivePoint.fromPrivateKey(privKey);
    const inputs: any[] = [];
    

    for (let i = 0; i < numSignatures; i++) {
        const msg = crypto.randomBytes(32);

        const sig: SignatureType = p256.sign(msg, privKey);
        const r: bigint = sig.r;
        const s: bigint = sig.s;
        const r_array = bigint_to_array(43, 6, r);
        const s_array = bigint_to_array(43, 6, s);
        const pub0array = bigint_to_array(43, 6, pubKey.x);
        const pub1array = bigint_to_array(43, 6, pubKey.y);
        const msgArray = bigint_to_array(43, 6, BigInt('0x' + msg.toString('hex')));

        const input = [
            r_array.toString(),
            s_array.toString(),
            msgArray.toString(),
            pub0array.toString(),
            pub1array.toString()
        ];

        inputs.push(input);
    }

    const fileOutput = {
        "start_pub_input": inputs[0],
        "signatures": inputs.slice(1, inputs.length),
    };

    // console.log(fileOutput);

    fs.writeFileSync(
        "src/data/batch.json",
        JSON.stringify(fileOutput)
    );
};

main();