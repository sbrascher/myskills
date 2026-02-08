using System.Collections.Generic;

namespace SeuProjeto.Application.Common
{
    public class PagedQueryResponse<T>
    {
        public int TotalItems { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public IEnumerable<T> Data { get; set; } = new List<T>();

        public int TotalPages => (int)System.Math.Ceiling(TotalItems / (double)PageSize);
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
    }
}
