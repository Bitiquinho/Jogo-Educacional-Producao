/* register_types.cpp */

#include "register_types.h"
#include "object_type_db.h"
#include "postgresql.h"

void register_postgresql_types() 
{
    ObjectTypeDB::register_type<PSQLDatabase>();
}

void unregister_postgresql_types() 
{
    //nothing to do here
} 
