import Text "mo:base/Text";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import List "mo:base/List";

import Types "types/types";
import Settings "eternal/settings";
// import Lib "lib";
import IC "ic/manager-ic";
import JWT "token/jwt";
import { WEEK; DAY; HOUR; MINUTE; SECOND } "mo:time-consts";
import Map "mo:map/Map";
// import FHM "mo:StableHashMap/FunctionalStableHashMap";

import Debug "mo:base/Debug";

//**Optional: IConsumer*//
import Interfaces "interfaces/iconsumer";
import Errors "mo:cbor/Errors";

actor Rbac {
  //**TEMPLATE**//
  type Errors = Types.Errors;
  type Duration = Types.Duration;
  type Scaner = Types.Scaner;
  type Admin = Types.Admin;
  type User = Types.User;
  type Role = Types.Role;
  type Permission = Types.Permission;
  type Admins = Types.Admins;
  type Users = Types.Users;
  type Roles = Types.Roles;
  type Permissions = Types.Permissions;
  type ListRelatedRP = Types.ListRelatedRP;
  type ObjectRef = Types.ObjectRef;
  type CountRef = Types.CountRef;
  type RelatedRP = Types.RelatedRP;
  type JTI = Types.JTI;
  type Token = Types.Token;
  type AuthClient = Types.AuthClient;

  public shared ({ caller }) func whoami_caller() : async Text {
    Principal.toText(caller);
  };
  public shared ({ caller }) func canister_id() : async Principal {
    Principal.fromActor(Rbac);
  };
  private func self() : Principal {
    Principal.fromActor(Rbac);
  };
  private func is_controller(caller : Principal) : async Bool {
    Array.find<Admin>(await controllers(), func p = caller == p) != null;
  };
  private func controllers() : async Admins {
    ((await IC.Manager.canister_status({ canister_id = self() })).settings.controllers);
  };

  //**Rbac**//
  //**Store**//
  private let { n32hash } = Map;
  private let { thash } = Map;
  private let { phash } = Map;

  private stable var _acting_clients = Map.new<Principal, AuthClient>(phash);

  private stable var _list_users = Map.new<User, User>(phash);
  private stable var _list_roles = Map.new<Role, CountRef>(thash); //reference where Nat count binding roles
  private stable var _list_permissions = Map.new<Permission, CountRef>(thash); //reference  where Nat count binding permissions

  private stable var _associated_role_permission = Map.new<Role, Permissions>(thash);
  private stable var _associated_user_role = Map.new<User, Roles>(phash);
  //**Store**//

  //**Dev**//
  //**Add an administrator to the user list if he is assigned as one of the canister controllers
  //Sample: dfx canister update-settings rbac --add-controller xxxxx-xxxxx-xxxxx-...-xxxxx
  public shared ({ caller }) func init() : async Result.Result<Admins, Errors> {
    if (await is_controller(caller)) {
      let admins = await controllers();
      for (a in admins.vals()) {
        ignore Map.put(_list_users, phash, a, a);
      };
      #ok(admins);
    } else {
      return #err(#access_error);
    };
  };
  //test dev
  public shared ({ caller }) func status() : async Result.Result<{ cycles : Nat; freezing_threshold : Nat; memory_size : Nat; module_hash : ?Blob; settings : Types.definite_canister_settings; status : { #running; #stopped; #stopping } }, Errors> {
    if (await is_controller(caller)) {
      #ok(await IC.Manager.canister_status({ canister_id = self() }));
    } else { return #err(#access_error) };
  };
  //**Dev**//

  //Controller auth-client
  private func controller(caller : Principal, client : AuthClient) : Result.Result<Bool, Errors> {
    let c : ?AuthClient = Map.get<Principal, AuthClient>(_acting_clients, phash, caller);
    switch (c) {
      case (null) { return #err(#invalid_client) };
      case (?c) {
        if (Principal.equal(c.token.payload.principal, caller)) {
          return #ok(true);
        };
      };
    };
    #err(#invalid_token);
  };
  //**users**//
  public shared ({ caller }) func _users_() : async Result.Result<Users, Errors> {
    if (await is_controller(caller)) {
      let array = Iter.toArray<User>(Map.vals(_list_users));
      return #ok(array);
    } else { return #err(#access_error) };
  };
  //admin
  public shared ({ caller }) func add_admin(user : User) : async Result.Result<User, Errors> {
    if (await is_controller(caller)) {
      let status = await IC.Manager.canister_status({
        canister_id = self();
      });
      let settings : Types.definite_canister_settings = status.settings;
      let controllers : Admins = status.settings.controllers;
      var list = List.nil<Admin>();
      list := List.push<Admin>(user, list);
      let iter = Array.vals<Admin>(controllers);
      for (v in iter) { list := List.push<Admin>(v, list) };
      let new_settings : Types.definite_canister_settings = {
        controllers = List.toArray(list);
        compute_allocation = settings.compute_allocation;
        memory_allocation = settings.memory_allocation;
        freezing_threshold = settings.freezing_threshold;
      };
      await IC.Manager.update_settings({
        canister_id = self();
        settings = new_settings;
        sender_canister_version = null;
      });
      // ignore await init();
      ignore Map.put(_list_users, phash, user, user);
      return #ok(user);
    } else { return #err(#access_error) };
  };
  //admin
  public shared ({ caller }) func delete_admin(user : User) : async Result.Result<User, Errors> {
    if (await is_controller(caller)) {
      let status = await IC.Manager.canister_status({
        canister_id = self();
      });
      let settings : Types.definite_canister_settings = status.settings;
      let controllers : Admins = status.settings.controllers;
      var list = List.nil<Admin>();
      let iter = Array.vals<Admin>(controllers);
      for (v in iter) {
        if (Principal.equal(v, user)) {} else {
          list := List.push<Principal>(v, list);
        };
      };
      let new_settings : Types.definite_canister_settings = {
        controllers = List.toArray(list);
        compute_allocation = settings.compute_allocation;
        memory_allocation = settings.memory_allocation;
        freezing_threshold = settings.freezing_threshold;
      };
      await IC.Manager.update_settings({
        canister_id = self();
        settings = new_settings;
        sender_canister_version = null;
      });
      Map.delete(_list_users, phash, user);
      return #ok(user);
    } else { return #err(#access_error) };
  };
  public shared ({ caller }) func add_user(user : User, client : AuthClient) : async Result.Result<User, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (Bool.equal(Map.has<User, User>(_list_users, phash, user), false)) {
            ignore Map.put(_list_users, phash, user, user);
            return #ok(user);
          } else {
            return #err(#contain);
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func delete_user(user : User, client : AuthClient) : async Result.Result<User, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (Bool.equal(Map.has<User, User>(_list_users, phash, user), true)) {
            Map.delete(_list_users, phash, user);
            return #ok(user);
          } else {
            return #err(#not_contain);
          };
        };
        return #err(#access_error);
      };
    };
  };
   public shared ({ caller }) func contains_user(user : User, client : AuthClient) : async Result.Result<User, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (Bool.equal(Map.has<User, User>(_list_users, phash, user), true)) {
            return #ok(user);
          } else {
            return #err(#not_contain);
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func users(client : AuthClient) : async Result.Result<Users, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          let array = Iter.toArray<User>(Map.vals(_list_users));
          return #ok(array);
        };
        return #err(#access_error);
      };
    };
  };
  //**users**//
  //**roles**//
  public shared ({ caller }) func add_role(role : Role, client : AuthClient) : async Result.Result<Role, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (Bool.equal(Map.has<Role, CountRef>(_list_roles, thash, role), false)) {
            ignore Map.put(_list_roles, thash, role, 0);
            return #ok(role);
          } else {
            return #err(#contain);
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func delete_role(role : Role, client : AuthClient) : async Result.Result<Role, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          let v : ?Nat = Map.get<Role, CountRef>(_list_roles, thash, role);
          switch (v) {
            case (null) { return #err(#not_contain) };
            case (?v) {
              if (Nat.equal(v, 0)) {
                Map.delete(_list_roles, thash, role);
                return #ok(role);
              } else {
                return #err(#error_delete);
              };
            };
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func get_role(role : Role, client : AuthClient) : async Result.Result<ObjectRef, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          var obj : ?(Role, CountRef) = Map.find<Role, CountRef>(_list_roles, func (key, value) = key == role);
          switch (obj) {
            case (null) { return #err(#not_contain) };
            case (?obj) {
              let (r, cf) = obj;
              return #ok({name = r; count_ref = cf});
            };
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func roles(client : AuthClient) : async Result.Result<Roles, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          let array = Iter.toArray<Role>(Map.keys(_list_roles));
          return #ok(array);
        };
        return #err(#access_error);
      };
    };
  };
  //**roles**//
  //**permissions**//
  public shared ({ caller }) func add_permission(permission : Permission, client : AuthClient) : async Result.Result<Permission, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (Bool.equal(Map.has<Permission, Nat>(_list_permissions, thash, permission), false)) {
            ignore Map.put(_list_permissions, thash, permission, 0);
            return #ok(permission);
          } else {
            return #err(#contain);
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func delete_permission(permission : Permission, client : AuthClient) : async Result.Result<Permission, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          let v : ?Nat = Map.get<Permission, Nat>(_list_permissions, thash, permission);
          switch (v) {
            case (null) { return #err(#not_contain) };
            case (?v) {
              if (Nat.equal(v, 0)) {
                Map.delete(_list_permissions, thash, permission);
                return #ok(permission);
              } else {
                return #err(#error_delete);
              };
            };
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func get_permission(permission : Permission, client : AuthClient) : async Result.Result<ObjectRef, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          var obj : ?(Permission, CountRef) = Map.find<Permission, CountRef>(_list_permissions, func (key, value) = key == permission);
          switch (obj) {
            case (null) { return #err(#not_contain) };
            case (?obj) {
              let (p, cf) = obj;
              return #ok({name = p; count_ref = cf});
            };
          };
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func permissions(client : AuthClient) : async Result.Result<Permissions, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          let array = Iter.toArray<Permission>(Map.keys(_list_permissions));
          return #ok(array);
        };
        return #err(#access_error);
      };
    };
  };
  //**permissions**//
  //**bindings**//
  private func increment_ref_permission(permission : Permission) {
    let n : ?Nat = Map.get<Permission, CountRef>(_list_permissions, thash, permission);
    switch (n) {
      case (null) {};
      case (?n) {
        ignore Map.replace<Permission, CountRef>(_list_permissions, thash, permission, n + 1);
      };
    };
  };
  private func decrement_ref_permission(permission : Permission) {
    let n : ?Nat = Map.get<Permission, CountRef>(_list_permissions, thash, permission);
    switch (n) {
      case (null) {};
      case (?n) {
        ignore Map.replace<Permission, CountRef>(_list_permissions, thash, permission, n - 1);
      };
    };
  };
  private func increment_ref_role(role : Role) {
    let n : ?Nat = Map.get<Role, CountRef>(_list_permissions, thash, role);
    switch (n) {
      case (null) {};
      case (?n) {
        ignore Map.replace<Role, CountRef>(_list_permissions, thash, role, n + 1);
      };
    };
  };
  private func decrement_ref_role(role : Role) {
    let n : ?Nat = Map.get<Role, CountRef>(_list_roles, thash, role);
    switch (n) {
      case (null) {};
      case (?n) {
        ignore Map.replace<Role,CountRef>(_list_roles, thash, role, n - 1);
      };
    };
  };
  public shared ({ caller }) func bind_permission(permission : Permission, role : Role, client : AuthClient) : async Result.Result<Permissions, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (
            (Bool.equal(Map.has<Permission, CountRef>(_list_permissions, thash, permission), true)) and (Bool.equal(Map.has<Role, Nat>(_list_roles, thash, role), true))
          ) {
            let permissions : ?Permissions = Map.get<Role, Permissions>(_associated_role_permission, thash, role);
            switch (permissions) {
              case (?permissions) {
                var list = List.fromArray<Permission>(permissions);
                let v = List.find<Permission>(list, func p = permission == p);
                switch (v) {
                  case (?v) { return #err(#contain) };
                  case (null) {
                    list := List.push<Permission>(permission, list);
                  };
                };
                increment_ref_permission(permission);
                ignore Map.replace<Role, Permissions>(_associated_role_permission, thash, role, List.toArray(list));
                return #ok(List.toArray(list));
              };
              case (null) {
                increment_ref_permission(permission);
                ignore Map.put<Role, Permissions>(_associated_role_permission, thash, role, [permission]);
                return #ok([permission]);
              };
            };
          };
          return #err(#not_contain);
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func unbind_permission(permission : Permission, role : Role, client : AuthClient) : async Result.Result<Permissions, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (
            (Bool.equal(Map.has<Permission, CountRef>(_list_permissions, thash, permission), true)) and (Bool.equal(Map.has<Role, Nat>(_list_roles, thash, role), true))
          ) {
            let permissions : ?Permissions = Map.get<Role, Permissions>(_associated_role_permission, thash, role);
            switch (permissions) {
              case (?permissions) {
                var list = List.fromArray<Permission>(permissions);
                list := List.filter<Permission>(list, func p = permission != p);
                let array = List.toArray(list);
                decrement_ref_permission(permission);
                ignore Map.replace<Role, Permissions>(_associated_role_permission, thash, role, array);
                return #ok(array);
              };
              case (null) {
                return #err(#unbind_failed);
              };
            };
          };
          return #err(#not_contain);
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func bind_role(user : User, role : Role, client : AuthClient) : async Result.Result<Roles, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (
            (Bool.equal(Map.has<Role, CountRef>(_list_roles, thash, role), true)) and (Bool.equal(Map.has<User, User>(_list_users, phash, user), true))
          ) {
            let roles : ?[Role] = Map.get<User, Roles>(_associated_user_role, phash, user);
            switch (roles) {
              case (?roles) {
                var list = List.fromArray<Role>(roles);
                let v = List.find<Role>(list, func p = role == p);
                switch (v) {
                  case (?v) { return #err(#contain) };
                  case (null) { list := List.push<Role>(role, list) };
                };
                increment_ref_role(role);
                ignore Map.replace<User, Roles>(_associated_user_role, phash, user, List.toArray(list));
                return #ok(List.toArray(list));
              };
              case (null) {
                increment_ref_role(role);
                ignore Map.put<User, Roles>(_associated_user_role, phash, user, [role]);
                return #ok([role]);
              };
            };
          };
          return #err(#not_contain);
        };
        return #err(#access_error);
      };
    };
  };
  public shared ({ caller }) func unbind_role(user : User, role : Role, client : AuthClient) : async Result.Result<Roles, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        if (client.participant == #Admin) {
          if (
            (Bool.equal(Map.has<Role, CountRef>(_list_roles, thash, role), true)) and (Bool.equal(Map.has<User, User>(_list_users, phash, user), true))
          ) {
            let roles : ?Roles = Map.get<User, Roles>(_associated_user_role, phash, user);
            switch (roles) {
              case (?roles) {
                var list = List.fromArray<Role>(roles);
                list := List.filter<Role>(list, func p = role != p);
                let array = List.toArray(list);
                decrement_ref_role(role);
                ignore Map.replace<User, Roles>(_associated_user_role, phash, user, array);
                return #ok(array);
              };
              case (null) {
                return #err(#unbind_failed);
              };
            };
          };
          return #err(#not_contain);
        };
        return #err(#access_error);
      };
    };
  };
  //**bindings**//
  //**gettings**//
  private func user_related_rp(caller : User) : ListRelatedRP {
    let roles = Map.get<User, Roles>(_associated_user_role, phash, caller);
    var list = List.nil<RelatedRP>();
    switch (roles) {
      case (null) { return list };
      case (?roles) {
        let iter = Array.vals<Role>(roles);
        for (role in iter) {
          let permissions = Map.get<Role, Permissions>(_associated_role_permission, thash, role);
          switch (permissions) {
            case (null) {
              list := List.push<RelatedRP>({ role = role; permissions = [] }, list);
            };
            case (?permissions) {
              list := List.push<RelatedRP>({ role = role; permissions = permissions }, list);
            };
          };
        };
      };
    };
    return list;
  };
  //**gettings**//
  //**Rbac**//

  //**Tokens**//
  private let default_entropy : Nat64 = 1234567890987654321; //any digit
  private let seed : Nat64 = default_entropy;
  private let jwt = JWT.JWT(seed);
  private let exp = Settings.exp_regarding * Settings.exp_interval; //token lifetime: DAY (24 hours)
  // private let exp = Settings.exp_regarding_short * Settings.exp_interval_short; //token lifetime 100 second (for sample)
  private func create_token(caller : Principal, lrp : ListRelatedRP) : Token {
    jwt.unsigned_token(Time.now() + exp, caller, lrp);
  };
  private func create_client(caller : Principal, token : Token) : async AuthClient {
    if (await is_controller(caller)) {
      let client : AuthClient = { participant = #Admin; token = token };
      return client;
    };
    return { participant = #User; token = token };
  };
  private func save(caller : Principal, client : AuthClient) {
    ignore Map.put(_acting_clients, phash, caller, client);
  };
  private func delete(caller : Principal, client : AuthClient) {
    Map.delete(_acting_clients, phash, caller);
  };
  private func new(caller : Principal, lrp : ListRelatedRP) : async AuthClient {
    let token = create_token(caller, lrp);
    let client : AuthClient = await create_client(caller, token);
    save(caller, client);
    client;
  };
  private func valid_lifetime(client : AuthClient) : Bool {
    client.token.payload.exp >= minute + Time.now(); // exp >= (period scan) + (current time)
  };
  public shared ({ caller }) func request_client() : async Result.Result<AuthClient, Errors> {
    let user : ?User = Map.get<User, User>(_list_users, phash, caller);
    switch (user) {
      case (null) { return #err(#invalid_caller) };
      case (?user) {
        let client : ?AuthClient = Map.get<Principal, AuthClient>(_acting_clients, phash, user);
        switch (client) {
          case (null) {
            let lrp : ListRelatedRP = user_related_rp(caller);
            let client = await new(caller, lrp);
            start_scaner(); //!!! start
            return #ok(client);
          };
          case (?client) {
            if (valid_lifetime(client)) {
              return #ok(client);
            } else {
              let lrp : ListRelatedRP = user_related_rp(caller);
              let new_client = await new(caller, lrp);
              start_scaner(); //!!! start
              return #ok(new_client);
            };
          };
        };
      };
    };
  };
  //**The same as "client request". A longer operation. A new client is always created.
  //Roles and Permissions are relevant at the time of creation**//
  public shared ({ caller }) func new_client() : async Result.Result<AuthClient, Errors> {
    let user : ?User = Map.get<User, User>(_list_users, phash, caller);
    switch (user) {
      case (null) { return #err(#invalid_caller) };
      case (?user) {
        let lrp : ListRelatedRP = user_related_rp(caller);
        let client = await new(caller, lrp);
        start_scaner(); //!!! start
        return #ok(client);
      };
    };
  };
  public shared ({ caller }) func delete_client(client : AuthClient) : async Result.Result<Bool, Errors> {
    switch (controller(caller, client)) {
      case (#err(e)) { return #err(e) };
      case (#ok(v)) {
        delete(caller, client);
        return #ok(true);
      };
    };
  };
  public shared ({ caller }) func valid_client() : async Bool {
    let client : ?AuthClient = Map.get<Principal, AuthClient>(_acting_clients, phash, caller);
    switch (client) {
      case (null) { return false };
      case (?client) {
        if (client.token.payload.exp > Time.now()) { return true } else {
          return false;
        };
      };
    };
    false;
  };
  //**Tokens**//

  //**Scaner**//
  private let minute = Settings.count_minute * MINUTE;
  // private let second = Settings.count_second * SECOND;//second
  private let period_minute : Duration = #nanoseconds minute; //period scan minute
  // private let period_second : Duration = #nanoseconds second; //period scan second
  private stable var scaner : Scaner = #OFF;
  private stable var timer_id : Nat = 0;
  private func hear_scaner() : Scaner { return scaner };
  public func status_scaner() : async Scaner { return scaner };
  private func stop_scaner() {
    Timer.cancelTimer(timer_id);
    timer_id := 0;
    scaner := #OFF;
  };
  private func start_scaner() {
    switch (hear_scaner()) {
      case (#ON) {};
      case (#OFF) {
        timer_id := Timer.recurringTimer(period_minute, job_scaner);//minute
        // timer_id := Timer.recurringTimer(period_second, job_scaner);//second
        scaner := #ON;
      };
    };
  };
  private func job_scaner() : async () {
    switch (hear_scaner()) {
      case (#ON) { await scan() };
      case (#OFF) {};
    };
  };
  private func scan() : async () {
    let size = Map.size<Principal, AuthClient>(_acting_clients);
    var i : Int = 0;
    if (size > 0) {
      let entries : Iter.Iter<(Principal, AuthClient)> = Map.entries<Principal, AuthClient>(_acting_clients);
      for ((p, c) in entries) {
        if (c.token.payload.exp <= Time.now()) {
          delete(p, c);
          i += i + 1;
          //**Notify, optional: IConsumer*//
          //If you implement the interface, you can start an alert. At the moment, only for canisters.
          //Sample canister:
          // let consumer : Interfaces.IConsumer= actor(Principal.toText(p));
          // await consumer.notify();
        };
      };
      if ((size - i) <= 0) {stop_scaner();};
    } else { stop_scaner();
    };
  };
  //**Scaner**//
  //**TEMPLATE**//
};
