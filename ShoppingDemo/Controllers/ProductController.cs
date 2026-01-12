using Microsoft.AspNetCore.Mvc;
using ShoppingDemo.Interfaces;
using ShoppingDemo.Models;

namespace ShoppingDemo.Controllers;

public class ProductController : Controller
{
    private readonly IProductService _productService;

    public ProductController(IProductService productService)
    {
        _productService = productService;
    }

    public IActionResult Index()
    {
        return View(_productService.GetAll());
    }

    public IActionResult Create()
    {
        return View();
    }

    [HttpPost]
    public IActionResult Create(Product product)
    {
        _productService.Add(product);
        return RedirectToAction(nameof(Index));
    }

    public IActionResult Edit(int id)
    {
        var product = _productService.GetById(id);
        return View(product);
    }

    [HttpPost]
    public IActionResult Edit(Product product)
    {
        _productService.Update(product);
        return RedirectToAction(nameof(Index));
    }

    public IActionResult Delete(int id)
    {
        var product = _productService.GetById(id);
        return View(product);
    }

    [HttpPost, ActionName("Delete")]
    public IActionResult DeleteConfirmed(int id)
    {
        _productService.Delete(id);
        return RedirectToAction(nameof(Index));
    }
}