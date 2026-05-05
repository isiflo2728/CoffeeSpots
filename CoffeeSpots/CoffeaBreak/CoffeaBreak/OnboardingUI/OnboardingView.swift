//
//  OnboardingView.swift
//  CoffeaBreak
//
//  Created by Isidoro Flores on 5/1/26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var path = NavigationPath()
    @State private var pulse = false
    enum OnboardingStep : Hashable {
        case permissions
        case createAccount
    }
    var body: some View {
        NavigationStack(path : $path) {
            ZStack{
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        let scale = min(size.width, size.height) / 400
                        let ox = (size.width - 400 * scale) / 2
                        let oy = (size.height - 400 * scale) / 2
                        context.translateBy(x: ox, y: oy)
                        context.scaleBy(x: scale, y: scale)

                        let cream = GraphicsContext.Shading.color(Color(red: 245/255, green: 237/255, blue: 216/255))
                        let darkBrown = GraphicsContext.Shading.color(Color(red: 44/255, green: 24/255, blue: 16/255))
                        let espresso = GraphicsContext.Shading.color(Color(red: 26/255, green: 14/255, blue: 8/255))

                        var body = Path()
                        body.move(to: CGPoint(x: 120, y: 195))
                        body.addLine(to: CGPoint(x: 280, y: 195))
                        body.addLine(to: CGPoint(x: 290, y: 350))
                        body.addQuadCurve(to: CGPoint(x: 274, y: 366), control: CGPoint(x: 290, y: 366))
                        body.addLine(to: CGPoint(x: 126, y: 366))
                        body.addQuadCurve(to: CGPoint(x: 110, y: 350), control: CGPoint(x: 110, y: 366))
                        body.closeSubpath()
                        context.fill(body, with: cream)

                        context.fill(Path(roundedRect: CGRect(x: 136, y: 214, width: 5, height: 140), cornerRadius: 2.5), with: darkBrown)
                        context.fill(Path(ellipseIn: CGRect(x: 120, y: 182, width: 160, height: 26)), with: cream)
                        context.fill(Path(ellipseIn: CGRect(x: 132, y: 190, width: 136, height: 16)), with: espresso)

                        var handle = Path()
                        handle.move(to: CGPoint(x: 283, y: 250))
                        handle.addCurve(to: CGPoint(x: 288, y: 326), control1: CGPoint(x: 368, y: 248), control2: CGPoint(x: 370, y: 326))
                        handle.addCurve(to: CGPoint(x: 283, y: 270), control1: CGPoint(x: 338, y: 326), control2: CGPoint(x: 336, y: 270))
                        handle.closeSubpath()
                        context.fill(handle, with: cream)

                        // Steam wisps
                        let wisps: [(CGFloat, Double)] = [(178, 0.0), (200, 0.4), (222, 0.75)]
                        for (baseX, phase) in wisps {
                            let progress = CGFloat((t * 0.4 + phase).truncatingRemainder(dividingBy: 1.0))
                            let y = 182 - progress * 85
                            let x = baseX + sin(progress * .pi * 2) * 7
                            let opacity = Double(1 - progress) * 0.65

                            var wisp = Path()
                            wisp.move(to: CGPoint(x: x, y: y))
                            wisp.addCurve(to: CGPoint(x: x - 5, y: y - 28),
                                          control1: CGPoint(x: x + 7, y: y - 9),
                                          control2: CGPoint(x: x - 7, y: y - 19))
                            wisp.addCurve(to: CGPoint(x: x + 5, y: y - 56),
                                          control1: CGPoint(x: x - 7, y: y - 37),
                                          control2: CGPoint(x: x + 7, y: y - 47))
                            context.stroke(wisp, with: .color(Color.white.opacity(opacity)), lineWidth: 3)
                        }
                    }
                }
                .frame(width: 650, height: 650)
                VStack {
                    Spacer()
                    
                    Text ("Enjoy a")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Coffee Break")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                   
                    Spacer()
                    Spacer()
                    Spacer()
                    Button{
                        path.append(OnboardingStep.permissions)
                    } label : {
                        Text("Start")
                    }
                    .padding(.horizontal, 40)
                     .padding(.vertical, 16)
                    .background(Color.white)
                    .foregroundColor(.brown)
                    .clipShape(.capsule)
                    .scaleEffect(pulse ? 0.85 : 1.0)
                    .onAppear{
                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
                    Spacer()
                    Spacer()
          
                }
            }
            .background(Color(red: 160/255, green: 115/255, blue: 70/255).ignoresSafeArea())
            .navigationDestination(for: OnboardingStep.self){ choice in
                switch choice {
                case .permissions:
                    PermissionsView(onContinue: {
                        path.append(OnboardingStep.createAccount)
                    })
                case .createAccount:
                    CreateAccountView()
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
