/* posgresql.h */

#ifndef POSTGRESQL_H
#define POSTGRESQL_H

#include "reference.h"

#include "ustring.h"
#include "list.h"
#include "map.h"

#include "pqxx/util.hxx"

#include "pqxx/connection.hxx"
#include "pqxx/result.hxx"
#include "pqxx/field.hxx"


class PSQLDatabase : public Reference 
{
    OBJ_TYPE( PSQLDatabase, Reference );

protected:
    static void _bind_methods();

public:
    PSQLDatabase();
    ~PSQLDatabase();
    
    void ConnectServer( String, String, String, String );
    Array Select( String, String, String );
    void Insert( String, String, String );
    void Update( String, String, String, String );
    
private:
    pqxx::connection* connection;
    
    bool IsBoolean( pqxx::field& );
    bool IsChar( pqxx::field& );
    bool IsInteger( pqxx::field& );
    bool IsFloat( pqxx::field& );
    bool IsString( pqxx::field& );
    bool IsBinary( pqxx::field& );
};

#endif 
