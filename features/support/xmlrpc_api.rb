require_relative 'xmlrpctest'

# api namespace class
class XMLRPCApiTest < XMLRPCBaseTest
  def getVersion
    @connection.call('api.getVersion')
  end

  def systemVersion
    @connection.call('api.systemVersion')
  end

  def getCountOfApiNamespaces
    namespaces = @connection.call('api.getApiNamespaces', @sid)
    count = 0
    count = namespaces.length unless namespaces.nil?
    count
  end

  #
  # Test lists all available api calls grouped by namespace.
  #
  def getCountOfApiCallListGroups
    call_list = @connection.call('api.getApiCallList', @sid)
    count = 0
    count = call_list.length unless call_list.nil?
    count
  end

  def getCountOfApiNamespaceCallList
    count = 0
    namespaces = @connection.call('api.getApiNamespaces', @sid)
    puts '    Spaces found: ' + namespaces.length.to_s
    namespaces.each do |ns|
      print '      Analyzing ' + ns[0] + '... '
      call_list = @connection.call('api.getApiNamespaceCallList', @sid, ns[0])
      if !call_list.nil?
        count += call_list.length
        puts 'Done'
      else
        puts 'Failed'
      end
    end
    count
  end
end
