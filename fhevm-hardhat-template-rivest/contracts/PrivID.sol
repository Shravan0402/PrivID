// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "fhevm/gateway/GatewayCaller.sol";

contract PrivID is Ownable2Step, GatewayCaller{

    
    struct PrivateId{
        euint64 uniqueId;
        euint8[] name;
        euint64 dob;
        euint8[] email;
        euint8[] state;
        euint8[] country;
    }

    mapping (address => PrivateId) ids;
    mapping (address => address[]) access;

    modifier onlyAccess(address _entity) {
        bool isAuthorized = false;
        for (uint i = 0; i < access[_entity].length; i++) {
            if (access[_entity][i] == msg.sender) {
                isAuthorized = true;
                break;
            }
        }
        require(isAuthorized, "Not authorized");
        _;
    }
    
    constructor() Ownable(msg.sender){}

    function giveAccess(address _entity) public{
        access[msg.sender].push(_entity);
    }

    function addId(einput _id, bytes calldata _idProof, einput[] memory _name, bytes[] calldata _nameProof, einput _dob, bytes calldata _dobProof,  einput[] memory _email, bytes[] calldata _emailProof, einput[] memory _state, bytes[] calldata _stateProof, einput[] memory _country, bytes[] calldata _countryProof) external{
        euint8[] memory name = new euint8[](_name.length);
        for(uint i=0; i<_name.length; i++){
            name[i] = TFHE.asEuint8(_name[i], _nameProof[i]);
        }
        euint8[] memory email = new euint8[](_email.length);
        for(uint i=0; i<_email.length; i++){
            email[i] = TFHE.asEuint8(_email[i], _emailProof[i]);
        }
        euint8[] memory state = new euint8[](_state.length);
        for(uint i=0; i<_state.length; i++){
            state[i] = TFHE.asEuint8(_state[i], _stateProof[i]);
        }
        euint8[] memory country = new euint8[](_country.length);
        for(uint i=0; i<_country.length; i++){
            country[i] = TFHE.asEuint8(_country[i], _countryProof[i]);
        }
        ids[msg.sender] = PrivateId(TFHE.asEuint64(_id, _idProof), name, TFHE.asEuint64(_dob, _dobProof), email, state, country);
    }

    function checkAge(address _user, euint64 _current_timestamp, euint64 _age_cutoff) public onlyAccess(_user) returns(ebool){
        return TFHE.ge(TFHE.sub(_current_timestamp, ids[_user].dob), _age_cutoff);
    }

    function checkId(address _user, euint64 _id) public onlyAccess(_user) returns(ebool){
        return(TFHE.eq(ids[_user].uniqueId, _id));
    }

    function checkCountry(address _user, euint8[] memory _country) public onlyAccess(_user) returns(ebool[] memory){
        euint8[] storage userCountries = ids[_user].country;
        require(userCountries.length == _country.length, "Mismatched country list lengths");
        ebool[] memory res = new ebool[](_country.length);
        for (uint i = 0; i < _country.length; i++) {
            res[i] = TFHE.ne(userCountries[i], _country[i]);
        }
        return res;
    } 

    function checkName(address _user, euint8[] memory _name) public onlyAccess(_user) returns(ebool[] memory){
        euint8[] storage userName = ids[_user].name;
        require(userName.length == _name.length, "Mismatched name list lengths");
        ebool[] memory res = new ebool[](_name.length);
        for (uint i = 0; i < _name.length; i++) {
            res[i] = TFHE.ne(userName[i], _name[i]);
        }
        return res;
    }

    function checkState(address _user, euint8[] memory _state) public onlyAccess(_user) returns(ebool[] memory){
        euint8[] storage userState = ids[_user].state;
        require(userState.length == _state.length, "Mismatched state list lengths");
        ebool[] memory res = new ebool[](_state.length);
        for (uint i = 0; i < _state.length; i++) {
            res[i] = TFHE.ne(userState[i], _state[i]);
        }
        return res;
    }

    function checkEmail(address _user, euint8[] memory _email) public onlyAccess(_user) returns(ebool[] memory){
        euint8[] storage userEmail = ids[_user].email;
        require(userEmail.length == _email.length, "Mismatched email list lengths");
        ebool[] memory res = new ebool[](_email.length);
        for (uint i = 0; i < _email.length; i++) {
            res[i] = TFHE.ne(userEmail[i], _email[i]);
        }
        return res;
    }

}