/* posgresql.h */

#ifndef POSTGRESQL_H
#define POSTGRESQL_H

#include "reference.h"

#include "ustring.h"
#include "list.h"
#include "map.h"

#include <pqxx/pqxx>


class PSQLDatabase : public Reference 
{
    OBJ_TYPE( PSQLDatabase, Reference );

protected:
    static void _bind_methods();

public:
    PSQLDatabase();
    ~PSQLDatabase();
    
    void ConnectServer( String, String, String, String );
    void CreateTable( String, String );
    Array LoadTable( String );
    void DeleteTable( String );
    Array Select( String, String, String );
    void Insert( String, String, String );
    
private:
    pqxx::connection* connection;
    
    bool IsBoolean( pqxx::result::field& );
    bool IsChar( pqxx::result::field& );
    bool IsInteger( pqxx::result::field& );
    bool IsFloat( pqxx::result::field& );
    bool IsString( pqxx::result::field& );
    bool IsBinary( pqxx::result::field& );
};

#endif 
