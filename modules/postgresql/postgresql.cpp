 /* posgresql.cpp */

#include "postgresql.h"

#include "pqxx/transaction.hxx"
#include "pqxx/binarystring.hxx"

#include "variant.h"

#include <string>
#include <exception>

#include <fstream>

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

Array PSQLDatabase::Select( String tableName, String fieldNames, String condition )
{ 
    std::string queryString = "SELECT ";
    queryString += fieldNames.utf8().get_data();
    queryString += " FROM ";
    queryString += tableName.utf8().get_data();
    queryString += " ";
    queryString += condition.utf8().get_data();
    queryString += ";";
    
    print_line( String::utf8( queryString.c_str() ) );
    
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
              for( auto resultField : resultLine )
              {
                  if( IsBinary( resultField ) )
                  {
                      pqxx::binarystring blob( resultField );
                      const uint8_t* dataBuffer = (const uint8_t*) blob.data();
                      size_t dataSize = blob.size();
                      if( dataSize > 0 )
                      {
                          ByteArray dataArray;
                          dataArray.resize( dataSize );
                          ByteArray::Write dataArrayWriter = dataArray.write();
                          for( size_t byteIndex = 0; byteIndex < dataSize; byteIndex++ )
                              dataArrayWriter[ byteIndex ] = dataBuffer[ byteIndex ];
                          row[ resultField.name() ] = dataArray;
                      }
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
    std::string queryString = "INSERT INTO ";
    queryString += tableName.utf8().get_data();
    queryString += "(";
    queryString += fieldNames.utf8().get_data(); 
    queryString += ") VALUES (";
    queryString += values.utf8().get_data();
    queryString += ");";
  
    if( connection )
    {
        try
        {
            pqxx::work transaction( *connection );
            transaction.exec( queryString );
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
}

void PSQLDatabase::Update( String tableName, String fieldName, String value, String condition )
{
    std::string queryString = "UPDATE ";
    queryString += tableName.utf8().get_data();
    queryString += " SET ";
    queryString += fieldName.utf8().get_data(); 
    queryString += "=(";
    queryString += value.utf8().get_data(); 
    queryString += ") ";
    queryString += condition.utf8().get_data();
    queryString += ";";
  
    if( connection )
    {
        try
        {
            pqxx::work transaction( *connection );
            transaction.exec( queryString );
        }
        catch( std::exception& exception )
        {
            print_line( String::utf8( exception.what() ) );
        }
    }
}

void PSQLDatabase::_bind_methods() 
{
    ObjectTypeDB::bind_method( _MD( "connect_server", "host", "database", "user", "password" ), &PSQLDatabase::ConnectServer );
    ObjectTypeDB::bind_method( _MD( "select", "table_name", "field_names", "condition" ), &PSQLDatabase::Select, DEFVAL( "" ), DEFVAL( "*" ) );
    ObjectTypeDB::bind_method( _MD( "insert", "table_name", "field_names", "values" ), &PSQLDatabase::Insert );
    ObjectTypeDB::bind_method( _MD( "update", "table_name", "field_name", "value", "condition" ), &PSQLDatabase::Update, DEFVAL( "" ) );
}


bool PSQLDatabase::IsBoolean( pqxx::field& field )
{
    return ( field.type() == 16 );
}

bool PSQLDatabase::IsInteger( pqxx::field& field )
{
    return ( field.type() >= 20 and field.type() <= 23 );
}

bool PSQLDatabase::IsFloat( pqxx::field& field )
{
    return ( field.type() == 700 or field.type() == 701 );
}

bool PSQLDatabase::IsBinary( pqxx::field& field )
{
    return ( field.type() == 17 );
}
