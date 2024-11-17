// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strings} from "@openzeppelin-contracts-5.0.1/utils/Strings.sol";
import {VerifiedEmail, UnverifiedEmail, EmailProofLib} from "vlayer-0.1.0/EmailProof.sol";
import {Proof} from "vlayer-0.1.0/Proof.sol";
import {Prover} from "vlayer-0.1.0/Prover.sol";
import {RegexLib} from "vlayer-0.1.0/Regex.sol";


contract IDProver is Prover{
    using EmailProofLib for UnverifiedEmail;

    function main(UnverifiedEmail calldata unverifiedEmail) public view returns(Proof memory, string memory){
        VerifiedEmail memory email = unverifiedEmail.verify();
        string memory target = "armanityours@gmail.com";
        string memory subject_target = "PrivId";
        require(compareStrings(email.from, target), "Fake email !!!");
        require(compareStrings(email.subject, subject_target), "Fake email !!!");
        return(proof(), email.body);
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

}