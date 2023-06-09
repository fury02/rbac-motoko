import Text "mo:base/Text";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Prelude "mo:base/Prelude";
import Option "mo:base/Option";
import Map "mo:map/Map";
import Result "mo:base/Result";
import Error "mo:base/Error";

import Types "types";

import Debug "mo:base/Debug";
import TrieMap "mo:base/TrieMap";

module {

  public class RBAC() {

    type Errors = Types.Errors;
    type Admin = Types.Admin;
    type User = Types.User;
    type Role = Types.Role;
    type Permission = Types.Permission;
    type Action = Types.Action;
    type canister_id = Types.Id; //Principal
    type CanisterSettings = Types.CanisterSettings; //Controllers
    type InternetComputer = Types.InternetComputer; //Interface
    let ic_actor : InternetComputer = actor ("aaaaa-aa");

    private let { n32hash } = Map;
    private let { thash } = Map;
    private let { phash } = Map;

    private var _self : Text = "";
    
    //role-permission
    //add
    public func bind_permission(
      caller : Principal,
      role : Role,
      permission : Permission,
      _admins : Map.Map<Nat32, Admin>,
      _roles : Map.Map<Text, Role>,
      _permissions : Map.Map<Text, Permission>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async Result.Result<?Permission, Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Permission>(_permissions, thash, permission);
      if (Bool.equal(has, false)) {
        return #err(#permission_does_not_exist);
      };
      let has2 = Map.has<Text, Role>(_roles, thash, role);
      if (Bool.equal(has2, false)) {
        return #err(#role_does_not_exist);
      };
      let permissions : ?[Permission] = Map.get<Role, [Permission]>(_associated_role_permission, thash, role);

      switch (permissions) {
        case (?permissions) {
          var list = List.fromArray<Permission>(permissions);
          let v = List.find<Role>(list, func p = permission == p);
          switch (v) {
            case (?v) { return #ok(null) };
            case (null) { list := List.push<Permission>(permission, list) };
          };
          let old = Map.replace<Role, [Permission]>(_associated_role_permission, thash, role, List.toArray(list));
          return #ok(?permission);
        };
        case (null) {
          let new = Map.put<Role, [Permission]>(_associated_role_permission, thash, role, [permission]);
          return #ok(?permission);
        };
      };
      return #err(#bind_permission_failed);
    };
    //delete permission
    public func unbind_permission(
      caller : Principal,
      role : Role,
      permission : Permission,
      _admins : Map.Map<Nat32, Admin>,
      _roles : Map.Map<Text, Role>,
      _permissions : Map.Map<Text, Permission>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async Result.Result<?[Permission], Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Permission>(_permissions, thash, permission);
      if (Bool.equal(has, false)) {
        return #err(#permission_does_not_exist);
      };
      let has2 = Map.has<Text, Role>(_roles, thash, role);
      if (Bool.equal(has2, false)) {
        return #err(#role_does_not_exist);
      };
      let permissions : ?[Permission] = Map.get<Role, [Permission]>(_associated_role_permission, thash, role);
      switch (permissions) {
        case (?permissions) {
          var list = List.fromArray<Permission>(permissions);
          list := List.filter<Permission>(list, func p = permission != p);
          let array = List.toArray(list);
          let old = Map.replace<Role, [Permission]>(_associated_role_permission, thash, role, array);
          return #ok(?array);
        };
        case (null) {
          return #err(#unbind_permission_failed);
        };
      };
      return #err(#unbind_permission_failed);
    };
    //get permissions for role
    //anyone can request. (While it remains) Todo
    public func demand_permissions_unsafe(
      caller : Principal,
      role : Role,
      _roles : Map.Map<Text, Role>,
      _permissions : Map.Map<Text, Permission>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async Result.Result<?[Permission], Errors> {
      let has = Map.has<Text, Permission>(_roles, thash, role);
      if (Bool.equal(has, false)) {
        return #err(#role_does_not_exist);
      };
      let permissions = Map.get<Role, [Permission]>(_associated_role_permission, thash, role);
      return #ok(permissions);
    };
    //get permissions for role
    public func demand_permissions(
      caller : Principal,
      role : Role,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _roles : Map.Map<Text, Role>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async Result.Result<?[Permission], Errors> {
      assert ((await is_admin(caller, _admins)) or (await is_users(caller, _users)));
      let has = Map.has<Text, Permission>(_roles, thash, role);
      if (Bool.equal(has, false)) {
        return #err(#role_does_not_exist);
      };
      let permissions = Map.get<Role, [Permission]>(_associated_role_permission, thash, role);
      return #ok(permissions);
    };
    //user-role
    public func bind_role(
      caller : Principal,
      user : User,
      role : Role,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _roles : Map.Map<Text, Role>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<?Role, Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Role>(_roles, thash, role);
      if (Bool.equal(has, false)) {
        return #err(#role_does_not_exist);
      };
      let has2 = Map.has<Nat32, User>(_users, n32hash, Principal.hash(user));
      if (Bool.equal(has2, false)) {
        return #err(#user_does_not_exist);
      };
      let roles : ?[Role] = Map.get<User, [Role]>(_associated_user_role, phash, user);
      switch (roles) {
        case (?roles) {
          var list = List.fromArray<Role>(roles);
          let v = List.find<Role>(list, func p = role == p);
          switch (v) {
            case (?v) { return #ok(null) };
            case (null) { list := List.push<Role>(role, list) };
          };
          let old = Map.replace<User, [Role]>(_associated_user_role, phash, user, List.toArray(list));

          return #ok(?role);
        };
        case (null) {
          let new = Map.put<User, [Role]>(_associated_user_role, phash, user, [role]);
          return #ok(?role);
        };
      };
      return #err(#bind_role_failed);
    };
    //delete role
    public func unbind_role(
      caller : Principal,
      user : User,
      role : Role,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _roles : Map.Map<Text, Role>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<?[Role], Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Role>(_roles, thash, role);
      if (Bool.equal(has, false)) {
        return #err(#role_does_not_exist);
      };
      let has2 = Map.has<Nat32, User>(_users, n32hash, Principal.hash(user));
      if (Bool.equal(has2, false)) {
        return #err(#user_does_not_exist);
      };
      let roles : ?[Role] = Map.get<User, [Role]>(_associated_user_role, phash, user);
      switch (roles) {
        case (?roles) {
          var list = List.fromArray<Role>(roles);
          list := List.filter<Role>(list, func p = role != p);
          let array = List.toArray(list);
          let old = Map.replace<User, [Role]>(_associated_user_role, phash, user, array);
          return #ok(?array);
        };
        case (null) {
          return #err(#unbind_role_failed);
        };
      };
      return #err(#unbind_role_failed);
    };
    //get roles for user
    //Another user can request another user's permissions
    public func demand_roles_unsafe(
      caller : Principal,
      user : User,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<?[Role], Errors> {
      assert ((await is_admin(caller, _admins)) or (await is_users(caller, _users)));
      if (Bool.equal(await is_users(user, _users), false)) {
        return #err(#user_does_not_exist);
      };
      let roles = Map.get<User, [Role]>(_associated_user_role, phash, user);
      return #ok(roles);
    };
    //get roles for user
    public func demand_roles(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<?[Role], Errors> {
      assert ((await is_admin(caller, _admins)) or (await is_users(caller, _users)));
      let roles = Map.get<User, [Role]>(_associated_user_role, phash, caller);
      return #ok(roles);
    };
    public func demand_user_permissions(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _roles : Map.Map<Text, Role>,
      _associated_user_role : Map.Map<User, [Role]>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async [Permission] {
      assert ((await is_admin(caller, _admins)) or (await is_users(caller, _users)));
      let user_roles : Result.Result<?[Role], Errors> = await demand_roles_unsafe(caller, caller, _admins, _users, _associated_user_role);
      var list = List.nil<Permission>();
      switch (user_roles) {
        case (#ok(v)) {
          switch (v) {
            case (?v) {
              let iter = Array.vals<Role>(v);
              for (r in iter) {
                var permissions : Result.Result<?[Permission], Errors> = await demand_permissions(caller, r, _admins, _users, _roles, _associated_role_permission);
                switch (permissions) {
                  case (#ok(permissions)) {
                    switch (permissions) {
                      case (?permissions) {
                        let iter_per = Array.vals<Permission>(permissions);
                        for (p : Permission in iter_per) {
                          list := List.push<Permission>(p, list);
                        };
                      };
                      case (null) {};
                    };
                  };
                  case (#err(e)) {};
                };
              };
            };
            case (null) { return [] };
          };
        };
        case (#err(e)) { return [] };
      };
      return List.toArray<Permission>(list);
    };
    //get permissions for user
    //Another user can request another user's permissions
    //If the caller will always be [auth ({caller}) ] users, then it is possible to make a completely isolated call.
    //But this deprives flexibility.
    public func demand_user_permissions_unsafe(
      caller : Principal,
      user : User,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _roles : Map.Map<Text, Role>,
      _associated_user_role : Map.Map<User, [Role]>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async [Permission] {
      assert ((await is_admin(caller, _admins)) or (await is_users(caller, _users)));
      let user_roles : Result.Result<?[Role], Errors> = await demand_roles_unsafe(caller, user, _admins, _users, _associated_user_role);
      var list = List.nil<Permission>();
      switch (user_roles) {
        case (#ok(v)) {
          switch (v) {
            case (?v) {
              let iter = Array.vals<Role>(v);
              for (r in iter) {
                var permissions : Result.Result<?[Permission], Errors> = await demand_permissions(user, r, _admins, _users, _roles, _associated_role_permission);
                switch (permissions) {
                  case (#ok(permissions)) {
                    switch (permissions) {
                      case (?permissions) {
                        let iter_per = Array.vals<Permission>(permissions);
                        for (p : Permission in iter_per) {
                          list := List.push<Permission>(p, list);
                        };
                      };
                      case (null) {};
                    };
                  };
                  case (#err(e)) {};
                };
              };
            };
            case (null) { return [] };
          };
        };
        case (#err(e)) { return [] };
      };
      return List.toArray<Permission>(list);
    };
    //**Operations related to the initial addition of data.**//
    //Admin
    //optimization:
    //adding administrators to the list in a canister
    public func initialization(
      canister_id : Text,
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
    ) : async () {
      _self := canister_id;
      assert (await is_controller(caller));
      let controllers : [Admin] = await canister_controllers();
      let iter = Array.vals<Admin>(controllers);
      for (principal in iter) {
        let id = Principal.hash(principal);
        let has = Map.has<Nat32, User>(_admins, n32hash, id);
        if (Bool.equal(has, false)) {
          ignore Map.put(_admins, n32hash, id, principal);
        };
      };
    };
    //There is a problem with updating the controller.
    public func add_admin(
      caller : Principal,
      admin : Admin,
      _admins : Map.Map<Nat32, Admin>,
    ) : async Result.Result<?Admin, Errors> {
      assert (await is_controller(caller));
      await update_settings(admin, #Add);
      let id = Principal.hash(admin);
      let has = Map.has<Nat32, Admin>(_admins, n32hash, id);
      if (Bool.equal(has, false)) {
        let val = Map.put(_admins, n32hash, id, admin);
        return #ok(val);
      };
      return #err(#adding_admin_failed);
    };
    public func delete_admin(
      caller : Principal,
      admin : Admin,
      _admins : Map.Map<Nat32, Admin>,
    ) : async Result.Result<Bool, Errors> {
      assert (await is_controller(caller));
      await update_settings(admin, #Delete);
      let id = Principal.hash(admin);
      Map.delete(_admins, n32hash, Principal.hash(admin));
      let has = Map.has<Nat32, Admin>(_admins, n32hash, id);
      if (Bool.equal(has, false)) {
        return #ok(true);
      };
      return #err(#delete_admin_failed);
    };
    public func admins(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
    ) : async [Admin] {
      let iter = Map.vals(_admins);
      let array = Iter.toArray<Admin>(iter);
      let admin : ?Admin = Array.find<Admin>(array, func p = caller == p);
      switch (admin) {
        case (?admin) { assert (true) };
        case (null) { assert (false) };
      };
      return array;
    };
    //Checks the participant in the Map storage lists
    private func is_admin(
      admin : Admin,
      _admins : Map.Map<Nat32, Admin>,
    ) : async Bool {
      let iter = Map.vals(_admins);
      let controllers = Iter.toArray<Admin>(iter);
      let principal : ?Admin = Array.find<Admin>(controllers, func p = admin == p);
      switch (principal) {
        case (?principal) { return true };
        case (null) { return false };
      };
    };
    //User
    public func add_user(
      caller : Principal,
      user : User,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
    ) : async Result.Result<?User, Errors> {
      assert (await is_admin(caller, _admins));
      let id = Principal.hash(user);
      let has = Map.has<Nat32, User>(_users, n32hash, id);
      if (Bool.equal(has, false)) {
        let val = Map.put(_users, n32hash, id, user);
        return #ok(val);
      };
      return #err(#adding_user_failed);
    };
    public func delete_user(
      caller : Principal,
      user : User,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<Bool, Errors> {
      assert (await is_admin(caller, _admins));
      let id = Principal.hash(user);
      Map.delete(_users, n32hash, id);
      Map.delete<User, [Role]>(_associated_user_role, phash, user);
      let has = Map.has<Nat32, User>(_users, n32hash, id);
      if (Bool.equal(has, false)) {
        return #ok(true);
      };
      return #err(#delete_user_failed);
    };
    public func users(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
      _users : Map.Map<Nat32, User>,
    ) : async [User] {
      assert (await is_admin(caller, _admins));
      let iter = Map.vals(_users);
      let array = Iter.toArray<User>(iter);
      return array;
    };
    private func is_users(
      user : User,
      _users : Map.Map<Nat32, User>,
    ) : async Bool {
      let iter = Map.vals(_users);
      let array = Iter.toArray<User>(iter);
      let v : ?User = Array.find<User>(array, func p = user == p);
      switch (v) {
        case (?v) { return true };
        case (null) { return false };
      };
      return false;
    };
    //Role
    public func add_role(
      caller : Principal,
      role : Role,
      _admins : Map.Map<Nat32, Admin>,
      _roles : Map.Map<Text, Role>,
    ) : async Result.Result<?Role, Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Role>(_roles, thash, role);
      if (Bool.equal(has, false)) {
        let val = Map.put(_roles, thash, role, role);
        return #ok(val);
      };
      return #err(#adding_role_failed);
    };
    public func delete_role(
      caller : Principal,
      role : Role,
      _admins : Map.Map<Nat32, Admin>,
      _roles : Map.Map<Text, Role>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : async Result.Result<Bool, Errors> {
      return attempt_delete_role(role, _roles, _associated_role_permission, _associated_user_role);
    };
    private func attempt_delete_role(
      role : Role,
      _roles : Map.Map<Text, Role>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : Result.Result<Bool, Errors> {
      let p : ?[Permission] = Map.get(_associated_role_permission, thash, role);
      switch (p) {
        case (null) {
          let is_used = used_user_role(role, _associated_user_role);
          if (Bool.equal(is_used, false)) {
            Map.delete<Role, [Permission]>(_associated_role_permission, thash, role);
            Map.delete(_roles, thash, role);
            return #ok(true);
          } else {
            return #err(#error_delete_role_used);
          };
        };
        case (?p) {
          let size = Array.size<Permission>(p);
          if (size > 0) {
            return #err(#error_delete_role_not_empty);
          } else {
            let is_used = used_user_role(role, _associated_user_role);
            if (Bool.equal(is_used, false)) {
              Map.delete<Role, [Permission]>(_associated_role_permission, thash, role);
              Map.delete(_roles, thash, role);
              return #ok(true);
            } else {
              return #err(#error_delete_role_used);
            };
          };
        };
      };
      return #err(#delete_role_failed);
    };
    private func used_user_role(
      role : Role,
      _associated_user_role : Map.Map<User, [Role]>,
    ) : Bool {
      for (val : [Role] in Map.vals<User, [Role]>(_associated_user_role)) {
        let v : ?Permission = Array.find<Role>(val, func p = role == p);
        switch (v) {
          case (?v) { return true };
          case (null) {};
        };
      };
      return false;
    };
    public func roles(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
      _roles : Map.Map<Text, Role>,
    ) : async [Role] {
      assert (await is_admin(caller, _admins));
      let iter = Map.vals(_roles);
      let array = Iter.toArray<Role>(iter);
      return array;
    };
    public func add_permission(
      caller : Principal,
      permission : Permission,
      _admins : Map.Map<Nat32, Admin>,
      _permissions : Map.Map<Text, Permission>,
    ) : async Result.Result<?Permission, Errors> {
      assert (await is_admin(caller, _admins));
      let has = Map.has<Text, Permission>(_permissions, thash, permission);
      if (Bool.equal(has, false)) {
        let val = Map.put(_permissions, thash, permission, permission);
        return #ok(val);
      };
      return #err(#adding_permission_failed);
    };
    public func delete_permission(
      caller : Principal,
      permission : Permission,
      _admins : Map.Map<Nat32, Admin>,
      _permissions : Map.Map<Text, Permission>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : async Result.Result<Bool, Errors> {
      assert (await is_admin(caller, _admins));
      return attempt_delete_permission(permission, _permissions, _associated_role_permission);
    };
    private func attempt_delete_permission(
      permission : Permission,
      _permissions : Map.Map<Text, Permission>,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : Result.Result<Bool, Errors> {
      let is_used = used_role_permission(permission, _associated_role_permission);
      if (Bool.equal(is_used, false)) {
        Map.delete(_permissions, thash, permission);
        return #ok(true);
      } else {
        return #err(#error_delete_permission_used);
      };
      return #err(#error_delete_permission_used);
    };
    private func used_role_permission(
      permission : Permission,
      _associated_role_permission : Map.Map<Role, [Permission]>,
    ) : Bool {
      // vals<K, V>(map: Map<K, V>): Iter<V>
      for (val : [Permission] in Map.vals<Role, [Permission]>(_associated_role_permission)) {
        let v : ?Permission = Array.find<Permission>(val, func p = permission == p);
        switch (v) {
          case (?v) { return true };
          case (null) {};
        };
      };
      return false;
    };
    public func permissions(
      caller : Principal,
      _admins : Map.Map<Nat32, Admin>,
      _permissions : Map.Map<Text, Permission>,
    ) : async [Permission] {
      assert (await is_admin(caller, _admins));
      let iter = Map.vals(_permissions);
      let array = Iter.toArray<Permission>(iter);
      return array;
    };
    //Checks the Principal directly in the canister on the controller lists
    private func is_controller(admin : Admin) : async Bool {
      let controllers = await canister_controllers();
      let principal : ?Principal = Array.find<Admin>(controllers, func p = admin == p);
      switch (principal) {
        case (?principal) { return true };
        case (null) { return false };
      };
    };
    public func controllers(caller : Principal) : async [Admin] {
      let controllers = await canister_controllers();
      let principal : ?Principal = Array.find<Admin>(controllers, func p = caller == p);
      switch (principal) {
        case (?principal) { return controllers };
        case (null) { return [] };
      };
    };
    private func canister_controllers() : async [Principal] {
      let status = await ic_actor.canister_status({
        canister_id = Principal.fromText(_self);
      });
      let settings : CanisterSettings = status.settings;
      return settings.controllers;
    };
    private func update_settings(principal : Principal, action : Action) : async () {
      let status = await ic_actor.canister_status({
        canister_id = Principal.fromText(_self);
      });
      let settings : CanisterSettings = status.settings;
      let controllers : [Principal] = status.settings.controllers;
      var list = List.nil<Principal>();
      //update
      switch (action) {
        case (#Add) {
          list := List.push<Principal>(principal, list);
          let iter = Array.vals<Principal>(controllers);
          for (v in iter) {
            list := List.push<Principal>(v, list);
          };
        };
        case (#Delete) {
          let iter = Array.vals<Principal>(controllers);
          for (v in iter) {
            if (Principal.equal(v, principal)) {} else {
              list := List.push<Principal>(v, list);
            };
          };
        };
      };
      let new_settings : CanisterSettings = {
        controllers = List.toArray(list);
        compute_allocation = settings.compute_allocation;
        memory_allocation = settings.memory_allocation;
        freezing_threshold = settings.freezing_threshold;
      };
      await ic_actor.update_settings({
        canister_id = Principal.fromText(_self);
        settings = new_settings;
      });
    };
  };
};
