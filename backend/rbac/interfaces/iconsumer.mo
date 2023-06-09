import Types "../types/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";

module {
    public type IConsumer = actor { 
        notify : () -> async (); 
    };
};
