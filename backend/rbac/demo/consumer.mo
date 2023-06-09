import Types "../types/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Interfaces "../interfaces/irbac";
import Debug "mo:base/Debug";

actor Consumer{
    //**The consumer must implement the interface IConsumer
    //notify is called in a class that supports rbac tokens*//
    public shared ({caller}) func notify(): async (){ 
        //**Any code (may be: request_token or completion of the session)*//
    };
    //rbac tokens
    let rbac_id = "cgpjn-omaaa-aaaaa-qaakq-cai";
    let rbac : Interfaces.IRbac= actor (rbac_id);
    //tests:
    public func client() : async () {  Debug.print("client: " # debug_show (await rbac.request_client())); };
    public func valid() : async () {  Debug.print("valid: " # debug_show (await rbac.valid_client())); }
}