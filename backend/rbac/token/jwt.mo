import Text "mo:base/Text";
import Char "mo:base/Char";
import Time "mo:base/Time";
import Types "../types/types";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import List "mo:base/List";

import Settings "../eternal/settings";
import Fuzz "mo:fuzz";
import Prng "mo:prng";
 
module{
    type Alg = Types.Alg;
    type TypeToken = Types.TypeToken;
    type Token = Types.Token;
    type Header = Types.Header;
    type Payload  = Types.Payload;
    type ListRelatedRP = Types.ListRelatedRP;
    public class JWT(seed: Nat64) = self {
        private let _seed : Nat64 = seed;
        private let rng = Prng.Seiran128();
        private let alg : Alg =  #NONE;
        private let typ_unsign : TypeToken =  #UJWT;
        private let typ : TypeToken =  #JWT;
        private let header: Header = {
            typ = typ_unsign;
            alg = alg
        };
        rng.init(_seed);
        let fuzz = Fuzz.fromSeed(Nat64.toNat(_seed));
        private func token_nid() : Nat64 { rng.next(); };
        private func token_tid() : Text {  fuzz.text.randomAlphanumeric(Settings.length_bytes); };   
        private func default_header() : Header { header; };
        private func payload(
            exp: Time.Time, 
            principal: Principal, 
            lrp : ListRelatedRP) : Payload { 
            {
                nbf= "";
                iat= "";
                iss = "";  
                sub = "";   
                aud = "";  
                jti = token_tid();
                exp = exp; //time  
                principal= principal;
                lrp = lrp;  
            };
        };
        public func unsigned_token(
            exp: Time.Time, 
            principal: Principal, 
            lrp : ListRelatedRP) : Token { 
            {
                header = default_header(); 
                payload = payload(exp, principal, lrp);
            };
        };
    };          
}