use gpui::*;

struct MyModel { val: i32 }
struct MyView { model: gpui::Entity<MyModel> }

impl gpui::Render for MyView {
    fn render(&mut self, window: &mut gpui::Window, cx: &mut gpui::Context<Self>) -> impl gpui::IntoElement {
        self.model.update(cx, |model, cx| {
            model.val = 42;
            cx.notify();
        });
        gpui::div()
    }
}

fn main() {}
