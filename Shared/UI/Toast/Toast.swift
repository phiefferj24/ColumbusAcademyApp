//
//  Toast.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 9/7/22.
//

import SwiftUI

extension View {
    func toast<T: Toast>(isPresenting: Binding<Bool>, expiresAfter: Double = 2.0, _ toast: @escaping () -> T) -> some View {
        modifier(ToastModifier(isPresenting: isPresenting, expiresAfter: expiresAfter, toast: toast))
    }
}

struct ToastModifier<T: Toast>: ViewModifier {
    @Binding var isPresenting: Bool
    
    var expiresAfter: Double
    
    var toast: () -> T
    
    @State var task: Task<Void, Never>? = nil
    
    @ViewBuilder func main() -> some View {
        switch toast().type {
        case .dropdown:
            ZStack {
                if isPresenting {
                    toast()
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder func body(content: Content) -> some View {
        content
            .overlay {
                main()
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .animation(Animation.spring(), value: isPresenting)
            }
            .onChange(of: isPresenting) { newValue in
                task?.cancel()
                if newValue {
                    task = Task {
                        try? await Task.sleep(seconds: expiresAfter)
                        Task { @MainActor in
                            isPresenting = false
                        }
                    }
                }
            }
    }
}

enum ToastDisplayType {
    case dropdown
}

enum ToastAccessoryViewType {
    case systemImage(name: String, color: Color? = nil)
    case progress
}

protocol Toast: View {
    var type: ToastDisplayType { get }
}
