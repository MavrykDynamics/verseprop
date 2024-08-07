// ------------------------------------------------------------------------------
// Access Control Helper Functions Begin
// ------------------------------------------------------------------------------

// verify sender is admin
function onlyAdmin(const admins : set(address)) : unit is
block {

    const senderIsAdmin : bool = admins contains Mavryk.get_sender();
    if senderIsAdmin then skip else failwith(error_ONLY_ADMINISTRATOR_ALLOWED);

} with unit



// verify sender is manager
function onlyManager(const managers : set(address)) : unit is
block {

    const senderIsManager : bool = managers contains Mavryk.get_sender();
    if senderIsManager then skip else failwith(error_ONLY_MANAGER_ALLOWED);

} with unit



// verify sender is admin or manager
function onlyAdminOrManager(const admins : set(address); const managers : set(address)) : unit is
block {

    const senderIsAdmin : bool = admins contains Mavryk.get_sender();
    const senderIsManager : bool = managers contains Mavryk.get_sender();

    if senderIsAdmin or senderIsManager then skip else failwith(error_ONLY_ADMIN_OR_MANAGER_ALLOWED);

} with unit

// ------------------------------------------------------------------------------
// Access Control Helper Functions End
// ------------------------------------------------------------------------------

