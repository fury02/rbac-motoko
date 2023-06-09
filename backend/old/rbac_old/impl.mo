import Text "mo:base/Text";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Map "mo:map/Map";
import Result "mo:base/Result";
import Types "types";

import Lib "lib";

import Debug "mo:base/Debug";
import RBTree "mo:base/RBTree";
import Nat "mo:base/Nat";

actor Impl {
  //** template **//
  type Errors = Types.Errors;
  type Admin = Types.Admin;
  type User = Types.User;
  type Role = Types.Role;
  type Permission = Types.Permission;
  type Action = Types.Action;

  private let { n32hash } = Map;
  private let { thash } = Map;
  private let { phash } = Map;

  //stable structures
  private stable var _admins = Map.new<Nat32, Admin>(n32hash);
  private stable var _users = Map.new<Nat32, User>(n32hash);
  private stable var _roles = Map.new<Text, Role>(thash);
  private stable var _permissions = Map.new<Text, Permission>(thash);
  private stable var _associated_role_permission = Map.new<Role, [Permission]>(thash);
  private stable var _associated_user_role = Map.new<User, [Role]>(phash);

  private let rbac = Lib.RBAC();
   
  public shared ({ caller }) func whoami_caller() : async Text {
    return Principal.toText(caller);
  };
  public shared ({ caller }) func canister_id() : async Principal {
    return Principal.fromActor(Impl);
  };
  public shared ({ caller }) func bind_permission(role : Role, permission : Permission) : async Result.Result<?Permission, Errors> {
    return await rbac.bind_permission(caller, role, permission, _admins, _roles, _permissions, _associated_role_permission);
  };
  public shared ({ caller }) func unbind_permission(role : Role, permission : Permission) : async Result.Result<?[Permission], Errors> {
    return await rbac.unbind_permission(caller, role, permission, _admins, _roles, _permissions, _associated_role_permission);
  };
  public shared ({ caller }) func demand_permissions_unsafe(role : Role) : async Result.Result<?[Permission], Errors> {
    return await rbac.demand_permissions_unsafe(caller, role, _roles, _permissions, _associated_role_permission);
  };
  public shared ({ caller }) func demand_permissions(role : Role) : async Result.Result<?[Permission], Errors> {
    return await rbac.demand_permissions(caller, role, _admins, _users, _roles, _associated_role_permission);
  };
  public shared ({ caller }) func bind_role(user : User, role : Role) : async Result.Result<?Role, Errors> {
    return await rbac.bind_role(caller, user, role, _admins, _users, _roles, _associated_user_role);
  };
  public shared ({ caller }) func unbind_role(user : User, role : Role) : async Result.Result<?[Role], Errors> {
    return await rbac.unbind_role(caller, user, role, _admins, _users, _roles, _associated_user_role);
  };
  public shared ({ caller }) func demand_roles_unsafe(user : User) : async Result.Result<?[Role], Errors> {
    return await rbac.demand_roles_unsafe(caller, user, _admins, _users, _associated_user_role);
  };
  public shared ({ caller }) func demand_roles() : async Result.Result<?[Role], Errors> {
    return await rbac.demand_roles(caller, _admins, _users, _associated_user_role);
  };
  public shared ({ caller }) func demand_user_permissions() : async [Permission] {
    return await rbac.demand_user_permissions(caller, _admins, _users, _roles, _associated_user_role, _associated_role_permission);
  };
  public shared ({ caller }) func demand_user_permissions_unsafe(user : User) : async [Permission] {
    return await rbac.demand_user_permissions_unsafe(caller, user, _admins, _users, _roles, _associated_user_role, _associated_role_permission);
  };
  public shared ({ caller }) func add_admin(admin : Admin) : async Result.Result<?Admin, Errors> {
    return await rbac.add_admin(caller, admin, _admins);
  };
  public shared ({ caller }) func delete_admin(admin : Admin) : async Result.Result<Bool, Errors> {
    return await rbac.delete_admin(caller, admin, _admins);
  };
  public shared ({ caller }) func admins() : async [Admin] {
    return await rbac.admins(caller, _admins);
  };
  public shared ({ caller }) func add_user(user : User) : async Result.Result<?User, Errors> {
    return await rbac.add_user(caller, user, _admins, _users);
  };
  public shared ({ caller }) func delete_user(user : User) : async Result.Result<Bool, Errors> {
    return await rbac.delete_user(caller, user, _admins, _users, _associated_user_role);
  };
  public shared ({ caller }) func users() : async [User] {
    return await rbac.users(caller, _admins, _users);
  };
  public shared ({ caller }) func add_role(role : Role) : async Result.Result<?Role, Errors> {
    return await rbac.add_role(caller, role, _admins, _roles);
  };
  public shared ({ caller }) func delete_role(role : Role) : async Result.Result<Bool, Errors> {
    return await rbac.delete_role(caller, role, _admins, _roles,  _associated_role_permission, _associated_user_role);
  };
  public shared ({ caller }) func roles() : async [Role] {
    return await rbac.roles(caller, _admins, _roles);
  };
  public shared ({ caller }) func add_permission(permission : Permission) : async Result.Result<?Permission, Errors> {
    return await rbac.add_permission(caller, permission, _admins, _permissions);
  };
  public shared ({ caller }) func delete_permission(permission : Permission) : async Result.Result<Bool, Errors> {
    return await rbac.delete_permission(caller, permission, _admins, _permissions, _associated_role_permission);
  };
  public shared ({ caller }) func permissions() : async [Permission] {
    return await rbac.permissions(caller, _admins, _permissions);
  };
  public shared ({ caller }) func controllers() : async [Admin] {
    return await rbac.controllers(caller);
  };
  //1)dfx canister update-settings rbac --add-controller <canister_id_rbac>
  //2)dfx canister call rbac initialization
  //3)dfx canister call rbac add_admin "(principal \"<canister_id_or_principal>\")"
  public shared ({ caller }) func initialization() : async () {
    let canister_id = Principal.toText(Principal.fromActor(Impl));
    await rbac.initialization(canister_id, caller, _admins);
  };
  //** template **//
  
  // //1)dfx canister update-settings rbac --add-controller <canister_id_rbac>
  // //2)dfx canister call rbac initialization_usafe
  // public shared ({ caller }) func initialization_unsafe() : async () {
  //   let canister_id = Principal.toText(Principal.fromActor(Impl));
  //   await rbac.initialization(canister_id, Principal.fromActor(Impl), _admins);
  //   //Change the value below your stoic identity, it is different (private let  admin_stoic_identity)
  //   await initial_adm();
  //   await initial_filling();
  // };
 
  //local
  // - dfx canister update-settings rbac --add-controller bkyz2-fmaaa-aaaaa-qaaaq-cai
  // - dfx canister call rbac initialization_unsafe

  //ic
  // dfx canister --network=ic update-settings rbac --add-controller se3xx-ziaaa-aaaan-qdsta-cai
  // dfx canister call rbac initialization

  //** Your code **//

  //Sample:

  private var array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  //Role
  private let role_user_web_access_pages : Role = "WebAccessPages";
  private let role_empty : Role = "Emty";
  private let role_array_r : Role = "Role-array-r"; //read
  private let role_array_rw : Role = "Role-array-rw"; //read write
  private let role_array_rwd : Role = "Role-array-rwd"; //read write delete
  
  //Permission
  private let permission_access_page : Permission = "PageOneComponent";
  private let permission_access_page2 : Permission = "PageTwoComponent";
  private let permission_array_read : Permission = "Array-read";
  private let permission_array_write : Permission = "Array-write";
  private let permission_array_delete : Permission = "Array-delete";

  private let user = "ixrwc-uyxws-zdcjr-4wrcm-wsjkn-7avh5-eire6-v7u4r-cudh7-xbwg6-pae"; //(chromium)
  private let user2 = "53raf-ibe5d-ffv7e-uvaqa-nqbak-xczww-ajexj-6u5zz-4fzha-bz4on-uae"; //
  private let admin_stoic_identity = "uolge-vezhl-ofixo-6gnvl-3geuf-27q4b-niavt-hgi53-gvivv-xjthx-lae"; //stoic
  // private let admin_stoic_identity2 = "jg232-gb2jq-fxffi-fctj6-daeup-4gwlb-2z5vk-6hpgr-3vlxy-pwm2m-aqe"; //debug

  private func initial_adm() : async () {
    let adm : Result.Result<?User, Errors> = await add_admin(Principal.fromText(admin_stoic_identity));
    // let adm2 : Result.Result<?User, Errors> = await add_admin(Principal.fromText(admin_stoic_identity2));
  };

  private func initial_filling() : async () {
    //User
    let u : Result.Result<?User, Errors> = await add_user(Principal.fromText(user));
    let u2 : Result.Result<?User, Errors> = await add_user(Principal.fromText(admin_stoic_identity));
    let u3 : Result.Result<?User, Errors> = await add_user(Principal.fromText(user2));

    //Role
    let added0 : Result.Result<?Role, Errors> = await add_role(role_user_web_access_pages);
    let added2 : Result.Result<?Role, Errors> = await add_role(role_array_r);
    let added3 : Result.Result<?Role, Errors> = await add_role(role_array_rw);
    let added4 : Result.Result<?Role, Errors> = await add_role(role_array_rwd);
    let added5 : Result.Result<?Role, Errors> = await add_role(role_empty);

    //Permission
    let added_permission1 : Result.Result<?Permission, Errors> = await add_permission(permission_array_read);
    let added_permission2 : Result.Result<?Permission, Errors> = await add_permission(permission_array_write);
    let added_permission3 : Result.Result<?Permission, Errors> = await add_permission(permission_array_delete);
    let added_permission5 : Result.Result<?Permission, Errors> = await add_permission(permission_access_page);
    let added_permission6 : Result.Result<?Permission, Errors> = await add_permission(permission_access_page2);

    //Bind role-permission
    let bv0 : Result.Result<?Permission, Errors> = await bind_permission(role_array_rwd, permission_array_read);
    let bv1 : Result.Result<?Permission, Errors> = await bind_permission(role_array_rwd, permission_array_write);
    let bv2 : Result.Result<?Permission, Errors> = await bind_permission(role_array_rwd, permission_array_delete);
    let bv3 : Result.Result<?Permission, Errors> = await bind_permission(role_user_web_access_pages, permission_access_page);
    let bv4 : Result.Result<?Permission, Errors> = await bind_permission(role_user_web_access_pages, permission_access_page2);
    let bv5 : Result.Result<?Permission, Errors> = await bind_permission(role_array_rw, permission_array_read);
    let bv6 : Result.Result<?Permission, Errors> = await bind_permission(role_array_rw, permission_array_write);
    let bv7 : Result.Result<?Permission, Errors> = await bind_permission(role_array_r, permission_array_read);

    //User role add
    let add_user0 : Result.Result<?Role, Errors> = await bind_role(Principal.fromText(user), role_array_rw);
    let add_user1 : Result.Result<?Role, Errors> = await bind_role(Principal.fromText(user), role_empty);
    let add_user2 : Result.Result<?Role, Errors> = await bind_role(Principal.fromText(user), role_user_web_access_pages);

    let add_adm_user0 : Result.Result<?Role, Errors> = await bind_role(Principal.fromText(admin_stoic_identity), role_array_r);
  };

  public shared ({ caller }) func access_right_one_page() : async Bool {
    let permissions : [Permission] = await rbac.demand_user_permissions(caller, _admins, _users, _roles, _associated_user_role, _associated_role_permission);
    assert ((Array.find<Permission>(permissions, func p = "PageOneComponent" == p) != null) == true);
    return true;
  };

  public shared ({ caller }) func read_array() : async Result.Result<[Nat], Errors> {
    let permissions : [Permission] = await rbac.demand_user_permissions(caller, _admins, _users, _roles, _associated_user_role, _associated_role_permission);
    assert ((Array.find<Permission>(permissions, func p = "Array-read" == p) != null) == true);
    return #ok(array);
  };

};
