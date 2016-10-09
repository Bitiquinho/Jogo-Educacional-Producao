 /* posgresql.cpp */

#include "postgresql.h"

#include "image.h"
#include "drivers/png/image_loader_png.h"

#include <string>
#include <exception>

PSQLDatabase::PSQLDatabase() 
{
    connection = nullptr;
}

PSQLDatabase::~PSQLDatabase()
{
    if( connection )
    {
        connection->disconnect();
  
        delete connection;
    }
}

void PSQLDatabase::ConnectServer( String serverHost, String databaseName, String userName, String password ) 
{
    std::string optionsString;
    optionsString += "host=";
    optionsString += serverHost.utf8().get_data();
    optionsString += " dbname=";
    optionsString += databaseName.utf8().get_data();
    optionsString += " user=";
    optionsString += userName.utf8().get_data();
    optionsString += " password=";
    optionsString += password.utf8().get_data();
    
    try
    {
        connection = new pqxx::connection( optionsString );
    }
    catch( std::exception& exception )
    {
        print_line( String::utf8( exception.what() ) );
    }
}

void PSQLDatabase::CreateTable( String tableName, String fields ) 
{
    std::string workString = "CREATE TABLE ";
    workString += tableName.utf8().get_data();
    workString += " (";
    workString += fields.utf8().get_data();
    workString += ");";
  
    if( connection )
    {          
        try
        {
            pqxx::work transaction( *connection );
            transaction.exec( workString );
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
}

Array PSQLDatabase::LoadTable( String tableName ) 
{    
    return Select( tableName, "*", "" );
}

void PSQLDatabase::DeleteTable( String tableName )
{
    std::string workString = "DROP TABLE ";
    workString += tableName.utf8().get_data();
  
    if( connection )
    {
        try
        {
            pqxx::work transaction( *connection );
            transaction.exec( workString );
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
}

Array PSQLDatabase::Select( String tableName, String fieldNames, String condition )
{
    std::string queryString = "SELECT ";
    queryString += fieldNames.utf8().get_data();
    queryString += " FROM ";
    queryString += tableName.utf8().get_data();
    if( not condition.empty() )
    {
        queryString += " WHERE ";
        queryString += condition.utf8().get_data();
    }
    queryString += ";";
    
    Array rowsList;
    
    if( connection )
    {
        try
        {
          pqxx::work transaction( *connection );
          pqxx::result result = transaction.exec( queryString );
          for( pqxx::result::const_iterator resultLine = result.begin(); resultLine != result.end(); ++resultLine )
          {
              Dictionary row;
              for( pqxx::tuple::const_iterator resultField : resultLine )
              {
                  if( IsBinary( resultField ) )
                  {
                      pqxx::binarystring blob( resultField );
                      const void* data = blob.data();
                      //size_t dataSize = blob.size();
                      ImageLoaderPNG();
                      row[ resultField.name() ] = Image( (const uint8_t*) data );
                  }
                  else if( IsBoolean( resultField ) )
                      row[ resultField.name() ] = resultField.as<int>();
                  else if( IsInteger( resultField ) )
                      row[ resultField.name() ] = resultField.as<int>();
                  else if( IsBoolean( resultField ) )
                      row[ resultField.name() ] = resultField.as<double>();
                  else
                      row[ resultField.name() ] = String::utf8( (char*) resultField.c_str() );
              }
              
              rowsList.push_back( row );
          }
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
    
    return rowsList;
}

void PSQLDatabase::Insert( String tableName, String fieldNames, String values )
{
    std::string workString = "INSERT INTO ";
    workString += tableName.utf8().get_data();
    workString += "(";
    workString += fieldNames.utf8().get_data(); 
    workString += ") VALUES (";
    workString += values.utf8().get_data();
    workString += ");";
  
    if( connection )
    {
        try
        {
            pqxx::work transaction( *connection );
            transaction.exec( workString );
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
}

void PSQLDatabase::_bind_methods() 
{
    ObjectTypeDB::bind_method( "connect_server", &PSQLDatabase::ConnectServer );
    ObjectTypeDB::bind_method( "create_table", &PSQLDatabase::CreateTable );
    ObjectTypeDB::bind_method( "load_table", &PSQLDatabase::LoadTable );
    ObjectTypeDB::bind_method( "delete_table", &PSQLDatabase::DeleteTable );
    ObjectTypeDB::bind_method( "select", &PSQLDatabase::Select );
    ObjectTypeDB::bind_method( "insert", &PSQLDatabase::Insert );
}


bool PSQLDatabase::IsBoolean( pqxx::result::field& field )
{
    return ( field.type() == 16 );
}

bool PSQLDatabase::IsInteger( pqxx::result::field& field )
{
    return ( field.type() >= 20 and field.type() <= 23 );
}

bool PSQLDatabase::IsFloat( pqxx::result::field& field )
{
    return ( field.type() == 700 or field.type() == 701 );
}

bool PSQLDatabase::IsBinary( pqxx::result::field& field )
{
    return ( field.type() == 17 );
}
