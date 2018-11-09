module Entity
  module V1
    PaginatedEventLog = Helper::Pagination.paginated_entity_class(EventLog)
  end
end
