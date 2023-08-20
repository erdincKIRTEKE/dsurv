import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

actor Token {
    let owner : Principal = Principal.fromText("ga5hf-ofken-ih26g-eqzq2-yq3qc-f4fhq-7btsr-3y4v6-euifs-vp5e2-zqe");

    // dfx indentity get-principal

    Debug.print("Hello");
    let totalSupply : Nat = 1000000000;

    let symbol : Text = "DERS";
    private stable var balanceEntries : [(Principal, Nat)] = [];

    // creating ledger
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    if (balances.size() < 1) { balances.put(owner, totalSupply) };

    //checking ledger
    public query func balanceOf(who : Principal) : async Nat {

        let balance : Nat = switch (balances.get(who)) {
            case null 0;
            case (?result) result;

        };

        return balance;

        // if (balances.get(who) == null) { return 0 } else {
        //     return balances.get(who);
        // }; using if statement does not work because of the type checker. balance.get returns Nat? instead of Nat . balance.get returns an optional (typesafe null it can be null or a value )type so we use switch statement

    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public shared (msg) func payOut() : async Text {

        if (balances.get(msg.caller) == null) {
            let amount = 10000;
            // balances.put(msg.caller, amount); // this is not needed because we are using transfer function
            let result = await transfer(msg.caller, amount);
            return result;

        } else {
            return "Already claimed!";
        };
        // Debug.print(debug_show (msg.caller));
        // return "Success";

    };
    public shared (msg) func transfer(to : Principal, amount : Nat) : async Text {
        let fromBalance = await balanceOf(msg.caller);
        if (fromBalance > amount) {
            let newFromBalance : Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance : Nat = toBalance + amount;
            balances.put(to, newToBalance);

            return "Success";
        } else {

            return "Insufficient funds";
        };

    };

    system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries())

    };

    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        if (balances.size() < 1) { balances.put(owner, totalSupply) };
    };

};
