using ShoppingDemo.Interfaces;
using ShoppingDemo.Models;

namespace ShoppingDemo.Services;

public class ProductService : IProductService
{
    private static readonly List<Product> _products =
        [
            new Product { Id = 1, Name = "Laptop", Price = 1200 },
            new Product { Id = 2, Name = "Mouse", Price = 25 },
            new Product { Id = 3, Name = "Keyboard", Price = 75 }
        ];

    public List<Product> GetAll()
    {
        return _products;
    }

    public Product? GetById(int id)
    {
        return _products.FirstOrDefault(p => p.Id == id);
    }

    public void Add(Product product)
    {
        product.Id = _products.Max(p => p.Id) + 1;
        _products.Add(product);
    }

    public void Update(Product product)
    {
        var existing = GetById(product.Id);
        if (existing == null) return;

        existing.Name = product.Name;
        existing.Price = product.Price;
    }

    public void Delete(int id)
    {
        var product = GetById(id);
        if (product != null)
            _products.Remove(product);
    }
}
