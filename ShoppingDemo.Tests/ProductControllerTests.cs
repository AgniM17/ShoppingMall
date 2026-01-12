using Microsoft.AspNetCore.Mvc;
using Moq;
using ShoppingDemo.Controllers;
using ShoppingDemo.Interfaces;
using ShoppingDemo.Models;

namespace ShoppingDemo.Tests;

public class ProductControllerTests
{
    private readonly Mock<IProductService> _mockService;
    private readonly ProductController _controller;

    public ProductControllerTests()
    {
        _mockService = new Mock<IProductService>();
        _controller = new ProductController(_mockService.Object);
    }

    [Fact]
    public void Index_ReturnsViewResult_WithListOfProducts()
    {
        var products = new List<Product>
            {
                new Product { Id = 1, Name = "Laptop", Price = 1200 },
                new Product { Id = 2, Name = "Mouse", Price = 25 }
            };

        _mockService.Setup(s => s.GetAll()).Returns(products);

        var result = _controller.Index();

        var viewResult = Assert.IsType<ViewResult>(result);
        var model = Assert.IsAssignableFrom<IEnumerable<Product>>(viewResult.Model);
        Assert.Equal(2, model.Count());
    }

    [Fact]
    public void Create_Post_RedirectsToIndex()
    {
        var product = new Product { Name = "Keyboard", Price = 75 };

        var result = _controller.Create(product);

        _mockService.Verify(s => s.Add(product), Times.Once);
        var redirect = Assert.IsType<RedirectToActionResult>(result);
        Assert.Equal("Index", redirect.ActionName);
    }

    [Fact]
    public void Edit_Post_RedirectsToIndex()
    {
        var product = new Product { Id = 1, Name = "Updated", Price = 100 };

        var result = _controller.Edit(product);

        _mockService.Verify(s => s.Update(product), Times.Once);
        var redirect = Assert.IsType<RedirectToActionResult>(result);
        Assert.Equal("Index", redirect.ActionName);
    }

    [Fact]
    public void DeleteConfirmed_RemovesProduct_AndRedirects()
    {
        int productId = 1;

        var result = _controller.DeleteConfirmed(productId);

        _mockService.Verify(s => s.Delete(productId), Times.Once);
        var redirect = Assert.IsType<RedirectToActionResult>(result);
        Assert.Equal("Index", redirect.ActionName);
    }
}

